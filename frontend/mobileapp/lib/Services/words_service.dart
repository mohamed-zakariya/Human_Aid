import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/queries/words_query.dart';
import 'package:mobileapp/models/exercices_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../models/word.dart';

class WordsService {
  /// NEW: Fetches ALL words of a given level from the server and returns them as a List<Word>
  /// This is used to load all words at the beginning of the exercise
  static Future<List<Word>?> fetchAllWords(String level, String exerciseId) async {
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
        'exerciseId': exerciseId,
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

    // Convert all words to Word objects and return the entire list
    List<Word> words = [];
    for (var wordData in data) {
      words.add(Word.fromJson(wordData));
    }

    // Optionally shuffle the words to randomize the order
    words.shuffle();

    return words;
  }

  /// DEPRECATED: Keep this for backward compatibility, but now it uses fetchAllWords internally
  /// Fetches up to 10 random words of a given level from the server,
  /// then picks one at random and returns it as a `Word`.
  static Future<Word?> fetchRandomWord(String level, String exerciseId) async {
    final words = await fetchAllWords(level, exerciseId);
    
    if (words == null || words.isEmpty) {
      return null;
    }

    // Return a random word from the fetched list
    final randomIndex = Random().nextInt(words.length);
    return words[randomIndex];
  }

  // Get learnt data by specific learner
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
          return await client.query(
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