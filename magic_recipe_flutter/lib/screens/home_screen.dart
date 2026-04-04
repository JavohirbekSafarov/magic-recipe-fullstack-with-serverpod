import 'package:flutter/material.dart';
import 'package:magic_recipe_flutter/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _resultMessage;
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  bool _loading = false;

  void _callGenerateRecipe() async {
    try {
      setState(() {
        _errorMessage = null;
        _resultMessage = null;
        _loading = true;
      });
      final result = await client.recipes.generateRecipe(
        ingredients: _textEditingController.text,
      );

      setState(() {
        _errorMessage = null;
        _resultMessage = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _resultMessage = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
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
                child: resultDisplay(
                  resultMessage: _resultMessage,
                  errorMessage: _errorMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget resultDisplay({String? resultMessage, String? errorMessage}) {
    if (_resultMessage == null && _errorMessage == null) {
      return Center(
        child: Text('Ingredientlarni kiriting!'),
      );
    }
    return Container(
      color: resultMessage == null
          ? Colors.red.withAlpha(100)
          : Colors.green.withAlpha(100),
      child: resultMessage == null ? Text(errorMessage!) : Text(resultMessage),
    );
  }
}
