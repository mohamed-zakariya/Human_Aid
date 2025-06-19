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
  static Future<Word?> fetchRandomWord(String level, String exerciseId)
 async {
  final client = await GraphQLService.getClient();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString("userId");

  if (userId == null) {
    print("User ID not found.");
    return null;
  }

  final QueryOptions options = QueryOptions(
    document: gql(fetchWordsQuery),
    variables: {
      'level': level,
      'userId': userId,
      'exerciseId': exerciseId, // ✅ Add this
    },
  );

  final result = await client.query(options);

  final handledResult = await GraphQLService.handleAuthErrors(
    result: result,
    role: 'user',
    retryRequest: () => client.query(options),
  );

  if (handledResult == null || handledResult.hasException) {
    print("GraphQL Exception: ${handledResult?.exception}");
    return null;
  }

  final data = handledResult.data?['getWordForExercise'];

  if (data == null || data.isEmpty) return null;

  final randomIndex = Random().nextInt(data.length);
  return Word.fromJson(data[randomIndex]);
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
