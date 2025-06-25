import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/parent_service_query.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercices_progress.dart';
import '../models/overall_progress.dart';
import '../models/parent.dart';

class ParentService {


  static Future<List<Learner?>?> getChildrenData(String? parentId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("tokkennnn $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getChildrenDataQuery),
        variables: {"parentId": parentId},
      ),
    );

      // Handle auth errors & retry if needed
      QueryResult? finalResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: "parent",
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.query( // ✅ Removed the extra comma
            QueryOptions(
              document: gql(getChildrenDataQuery),
              variables: {"parentId": parentId},
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

        final List<dynamic>? rawData = finalResult.data?["getParentChildren"];

        if (rawData == null) {
          print("Login Failed: No data returned.");
          return null;
        }

        final List<Learner> data = rawData.map((item) => Learner.fromJson(item)).toList();
        print("done");
        return data;

      } else {

        print("Request still failed even after retry.");
        return null;

      }


  }

  static Future<bool> deleteLearner(String? parentId, String? passwordParent, String? usernameChild) async {
    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(deleteLearnerQuery),
        variables: {
          "parentId": parentId,
          "passwordParent": passwordParent,
          "usernameChild": usernameChild
        },
      ),
    );


    if (result.hasException) {
      print("Login Error: ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["deleteChild"];

    if (data == null) {
      print("Login Failed: No data returned.");
      return false;
    }
    print("delete userrrrrrrrrr ${data["success"]}");
    // bool finalResult = data["success"];
    return data["success"];
  }


  static Future<List<LearnerProgress?>?> getLearnerProgressbyDate(String? parentId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("tokkennnn $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getLearnerProgressbyDateQuery),
        variables: {"parentId": parentId},
      ),
    );

    // Handle auth errors & retry if needed
    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: "parent",
        retryRequest: () async {
          final client = await GraphQLService.getClient();
          return await client.query( // ✅ Removed the extra comma
            QueryOptions(
              document: gql(getLearnerProgressbyDateQuery),
              variables: {"parentId": parentId},
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

      final Map<String, dynamic>? rawData = finalResult.data?["getLearnerProgressbyDate"];

      if (rawData == null) {
        print("Login Failed: No data returned.");
        return null;
      }


      final LearnerProgress data = LearnerProgress.fromJson(rawData);
      print("done");
      return [data]; // Wrap in a List since function expects List<LearnerProgress?>

    } else {

      print("Request still failed even after retry.");
      return null;

    }

  }


  static Future<List<LearnerDailyAttempts>?> getProgressWithDate(String? parentId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("Token: $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getLearnerProgressbyDateQuery),
        variables: {"parentId": parentId},
      ),
    );

    // Handle authentication errors & retry if needed
    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "parent",
      retryRequest: () async {
        final client = await GraphQLService.getClient();
        return await client.query(
          QueryOptions(
            document: gql(getLearnerProgressbyDateQuery),
            variables: {"parentId": parentId},
          ),
        );
      },
    );

    // Check if finalResult is null
    if (finalResult == null || finalResult.hasException) {
      print("Error: ${finalResult?.exception?.toString()}");
      return null;
    }

    final List<dynamic>? rawData = finalResult.data?["getLearnerDailyAttempts"];

    if (rawData == null) {
      print("No data returned.");
      return null;
    }

    // Convert JSON response into Dart objects
    final learnerDailyAttempts = (rawData)
        .map((e) => LearnerDailyAttempts.fromJson(e))
        .toList();


    print("Data processing complete.");
    print(learnerDailyAttempts);
    return learnerDailyAttempts;
  }


  static Future<OverallProgress?> getLearnersProgress(String? parentId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("Token: $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getLearnerProgress),
        variables: {"parentId": parentId},
      ),
    );

    // Handle authentication errors & retry if needed
    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "parent",
      retryRequest: () async {
        final client = await GraphQLService.getClient();
        return await client.query(
          QueryOptions(
            document: gql(getLearnerProgress),
            variables: {"parentId": parentId},
          ),
        );
      },
    );

    // Check if finalResult is null
    if (finalResult == null || finalResult.hasException) {
      print("Error: ${finalResult?.exception?.toString()}");
      return null;
    }

    final dynamic rawData = finalResult.data?["getLearnerOverallProgress"];

    if (rawData == null) {
      print("No data returned.");
      return null;
    }

    // Convert JSON response into Dart objects
    final OverallProgress overallProgress = OverallProgress.fromJson(rawData as Map<String, dynamic>);


    print("Overall ID: ${overallProgress.id}");
    for (var userProgress in overallProgress.progress) {
      print("User: ${userProgress.name}");
      for (var exercise in userProgress.progressByExercise) {
        print("  Exercise ID: ${exercise.exerciseId}");
        print("    Correct: ${exercise.stats.totalCorrect.items}");
        print("    Incorrect: ${exercise.stats.totalIncorrect.items}");
      }
    }


    print("Data processing complete.");
    print(overallProgress);
    return overallProgress;
  }


  static Future<Parent?> getParentProfile(String? parentId) async {
    final client = await GraphQLService.getClient();

    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");
    print("tokkennnn $refreshToken");

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getParentProfileQuery),
        variables: {"parentId": parentId},
      ),
    );

    QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "parent",
      retryRequest: () async {
        final client = await GraphQLService.getClient();
        return await client.query(
          QueryOptions(
            document: gql(getParentProfileQuery),
            variables: {"parentId": parentId},
          ),
        );
      },
    );

    if (finalResult != null) {
      if (finalResult.hasException) {
        print("Login Error: ${finalResult.exception.toString()}");
        return null;
      }

      final dynamic rawData = finalResult.data?["parentProfile"];

      if (rawData == null) {
        print("Login Failed: No data returned.");
        return null;
      }

      final Parent parent = Parent.fromJson(rawData);
      print("Parent data fetched successfully");
      return parent;
    } else {
      print("Request still failed even after retry.");
      return null;
    }
  }


}

