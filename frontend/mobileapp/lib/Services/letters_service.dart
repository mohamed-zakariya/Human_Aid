import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/queries/letters_query.dart';
import 'package:mobileapp/graphql/queries/words_query.dart';
import 'package:mobileapp/models/exercices_progress.dart';
import 'package:mobileapp/models/letter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
// import '../graphql/queries/words_query.dart'  <-- Your actual query strings or placeholders
import '../models/word.dart';


class LettersService {

  // get learnt data by specific learner

  static Future<List<Letter>?> getLettersForLevel1() async {
    final client = await GraphQLService.getClient();
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("token: $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getLettersForExercise),
      ),
    );

    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "learner",
      retryRequest: () async {
        final client = await GraphQLService.getClient();
        return await client.query(
          QueryOptions(
            document: gql(getLettersForExercise), // ⚡ Use getLettersForExercise here, not getCorrectWordsbyId
          ),
        );
      },
    );

    if (finalResult != null) {
      if (finalResult.hasException) {
        print("Error fetching letters: ${finalResult.exception.toString()}");
        return null;
      }

      print("sssss ${finalResult.data}");

      final List<dynamic>? lettersData = finalResult.data?["getLettersForExercise"];
      if (lettersData == null) {
        print("No letters data returned.");
        return null;
      }

      List<Letter> letters = lettersData.map((letterJson) => Letter.fromJson(letterJson)).toList();

      print("Fetched ${letters.length} letters");
      print(letters[0]);
      return letters;
    } else {
      print("Request failed even after retry.");
      return null;
    }
  }

}
