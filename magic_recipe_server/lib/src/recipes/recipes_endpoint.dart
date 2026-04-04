import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:serverpod/serverpod.dart';

class RecipesEndpoint extends Endpoint {
  Future<String> generateRecipe(
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

    return responseText;
  }
}
