import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/queries/words_query.dart';

import '../graphql/graphql_client.dart';
// import '../graphql/queries/words_query.dart'  <-- Your actual query strings or placeholders
import '../models/word.dart';

class WordsService {
  /// Fetches up to 10 random words of a given level from the server,
  /// then picks one at random and returns it as a `Word`.
  /// 
  /// IMPORTANT: We handle "Unauthorized" errors via `handleAuthErrors`.
  static Future<Word?> fetchRandomWord(String level) async {
    final client = await GraphQLService.getClient();

    // Create the query options; replace `YOUR_QUERY_HERE` with the actual `gql(...)`
    final QueryOptions options = QueryOptions(
      document: gql(fetchWordsQuery),
      variables: {
        'level': level,
      },
    );

    // First attempt the query
    final result = await client.query(options);

    // If there's an Unauthorized error, handle token refresh & retry
    final handledResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: 'user', 
      retryRequest: () => client.query(options),
    );

    // If handleAuthErrors returned null, token refresh failed → no data
    if (handledResult == null) {
      return null;
    }

    // If there's still an exception after that, it's a different error
    if (handledResult.hasException) {
      print("GraphQL Exception: ${handledResult.exception}");
      return null;
    }

    // Extract data from the final QueryResult
    final data = handledResult.data?['getWordForExercise'];
    // Example: data might be a List of JSON objects: [{ _id, word, level }, ...]

    if (data == null || data.isEmpty) {
      // No words returned
      return null;
    }

    // Choose a random item from the list
    final randomIndex = Random().nextInt(data.length);
    final Map<String, dynamic> randomWordJson = data[randomIndex];

    return Word.fromJson(randomWordJson);
  }
}
