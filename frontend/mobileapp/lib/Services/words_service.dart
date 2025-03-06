// services/words_service.dart

import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/words_query.dart';
import '../models/word.dart'; // The Word model with {id, text, level}

class WordsService {
  /// Fetch up to 10 random words of a given level from server, 
  /// then pick one at random, and return it as a `Word`.
  static Future<Word?> fetchRandomWord(String level) async {
    final client = await GraphQLService.getClient();

    final QueryOptions options = QueryOptions(
      document: gql(fetchWordsQuery),
      variables: {
        'level': level,
      },
    );

    final result = await client.query(options);

    if (result.hasException) {
      print("GraphQL Exception: ${result.exception}");
      return null;
    }

    final data = result.data?['getWordForExercise'];
    // data should be a list of word objects: [{ _id, word, level }, ...]

    if (data == null || data.isEmpty) {
      // No words returned
      return null;
    }

    // Choose one random doc from the list
    final randomIndex = Random().nextInt(data.length);
    final Map<String, dynamic> randomWordJson = data[randomIndex];

    // Convert it to your `Word` model
    return Word.fromJson(randomWordJson);
  }
}
