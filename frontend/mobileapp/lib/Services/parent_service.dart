import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/parent_service_query.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/user_daily_attempts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercices_progress.dart';

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


  static Future<List<Learner?>?> getProgressWithDate(String? parentId) async {
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

      final UserDailyAttempts userDailyAttempts = finalResult.data?["getLearnerDailyAttempts"];

      if (userDailyAttempts == null) {
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

}

