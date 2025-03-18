import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/queries/words_query.dart';
import 'package:mobileapp/models/exercices_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

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



  // get learnt data by specific learner

  static Future<ExerciseProgress?> getLearntDataById(String? userId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("tokkennnn $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getCorrectWordsbyId),
        variables: {"userId": userId},
      ),
    );

    // Handle auth errors & retry if needed
    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: "learner",
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.query( // ✅ Removed the extra comma
            QueryOptions(
              document: gql(getCorrectWordsbyId),
              variables: {"userId": userId},
            ),
          );
        }
    );

    // Use finalResult instead of result
    if (finalResult != null) {
      // Process successful response
      if (finalResult.hasException) {
        print("Login Error: ${finalResult.exception.toString()}");
        return null;
      }
      print(finalResult.data);
      final ExerciseProgress exerciseProgress = ExerciseProgress.fromJson(finalResult.data?["getLearntWordsbyId"]);

      if (exerciseProgress == null) {
        print("Login Failed: No data returned.");
        return null;
      }

      print(exerciseProgress.correctWords);
      print("done");
      return exerciseProgress;

    } else {

      print("Request still failed even after retry.");
      return null;

    }

  }
}
