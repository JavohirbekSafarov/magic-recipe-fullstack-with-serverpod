import 'package:flutter/material.dart';
import 'package:magic_recipe_client/magic_recipe_client.dart';
import 'package:magic_recipe_flutter/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Recipe? _recipe;
  List<Recipe> _recipeHistory = [];

  String? _errorMessage;

  final _textEditingController = TextEditingController();

  bool _loading = false;

  void _callGenerateRecipe() async {
    try {
      setState(() {
        _errorMessage = null;
        _recipe = null;
        _loading = true;
      });
      final result = await client.recipes.generateRecipe(
        ingredients: _textEditingController.text,
      );

      setState(() {
        _errorMessage = null;
        _recipe = result;
        _loading = false;
        _recipeHistory.insert(0, result);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _recipe = null;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    client.recipes.getRecipes().then((favoriteRecipes) {
      setState(() {
        _recipeHistory = favoriteRecipes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.grey[300]),
              child: ListView.builder(
                itemCount: _recipeHistory.length,
                itemBuilder: (context, index) {
                  final recipe = _recipeHistory[index];
                  return ListTile(
                    title: Text(
                      '${recipe.text.substring(0, recipe.text.indexOf('\n'))}',
                    ),
                    subtitle: Text(
                      '${recipe.author} - ${recipe.date.toLocal()}',
                    ),
                    onTap: () {
                      _textEditingController.text = recipe.ingredients;
                      setState(() {
                        _recipe = recipe;
                      });
                    },
                    onLongPress: () {
                      client.recipes.deleteRecipe(recipe);
                      setState(() {
                        _recipeHistory.remove(recipe);
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Ingredientlarni kiriting',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _callGenerateRecipe,
                      child: _loading
                          ? const Text('Yuklanmoqda...')
                          : const Text('Retsep tuzish'),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ResultDisplay(
                        resultMessage: _recipe != null
                            ? '${_recipe?.author} orqali ${_recipe?.date} da tuzilgan restep:\n${_recipe?.text}'
                            : null,
                        errorMessage: _errorMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const ResultDisplay({
    super.key,
    this.resultMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Container(
        color: backgroundColor,
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
