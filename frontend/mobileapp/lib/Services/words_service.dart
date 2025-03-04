// services/words_service.dart
import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/words_query.dart';
import '../models/word.dart'; // If you want to use the Word model

class WordsService {
  static Future<String?> fetchRandomWord(String level) async {
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

    // The data from result.data?['getWordForExercise'] 
    // is typically a List of Maps
    final data = result.data?['getWordForExercise'];
    if (data == null || data.isEmpty) {
      return null;
    }

    // data might be up to 10 words from your Mongo aggregation.
    // Pick one at random:
    final randomIndex = Random().nextInt(data.length);
    final Map<String, dynamic> randomWord = data[randomIndex];

    // If you had a model:
    final Word model = Word.fromJson(randomWord);
    return model.text;

    // Otherwise, just return the raw string:
    // return randomWord['word'];
  }
}
