import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:magic_recipe_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class RecipesEndpoint extends Endpoint {
  Future<Recipe> generateRecipe(
    Session session, {
    required String ingredients,
  }) async {
    final geminiApiKey = session.passwords['geminiApiKey'];

    if (geminiApiKey == null) {
      throw Exception('Gemini API key topilmadi!');
    }

    final agent = Agent.forProvider(
      GoogleProvider(apiKey: geminiApiKey),
      chatModelName: 'gemini-2.5-flash-lite',
    );

    final prompt =
        'Generate a recipe using the following ingredients: $ingredients. '
        'Always put the title of the recipe in the first line, followed by the '
        'instructions. The recipe should be easy to follow and include all '
        'necessary steps.'
        'Return message in UZBEK language';

    final response = await agent.send(prompt);

    final responseText = response.output;

    if (responseText.isEmpty) {
      throw Exception('Gemini API javob bermadi!');
    }

    final recipe = Recipe(
      author: 'Gemini',
      text: responseText,
      date: DateTime.now(),
      ingredients: ingredients,
    );

    final recipeWithId = await Recipe.db.insertRow(session, recipe);

    return recipeWithId;
  }

  Future<List<Recipe>> getRecipes(Session session) async {
    return await Recipe.db.find(
      session,
      orderBy: (t) => t.date,
      orderDescending: true,
    );
  }

  Future<Recipe> deleteRecipe(Session session, Recipe recipe) async {
    return await Recipe.db.deleteRow(session, recipe);
  }
}
