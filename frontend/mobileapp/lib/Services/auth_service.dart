import 'dart:async';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/auth_login_query.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/parent.dart';
import 'package:mobileapp/models/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {


  static Future<Parent?> loginParent(String email, String password) async {
    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(loginParentQuery),
            variables: {
              "email": email,
              "password": password
            }
        )
    );

    if (result.hasException) {
      print("Login Error: ${result.exception.toString()}");
      return null;
    }

    final Map<String, dynamic>? data = result.data?["loginParent"];

    if(data == null){
      print("Login Failed: No data returned.");
      return null;
    }

    final Map<String, dynamic> parentData = data["parent"];
    final String accessToken = data["accessToken"];
    final String refreshToken = data["refreshToken"];


    GraphQLService.saveTokens(accessToken, refreshToken);

    return Parent.fromJson(parentData);

  }

  static Future<Learner?> loginLearner(String username, String password) async {
    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(loginUserQuery),
            variables: {
              "username": username,
              "password": password
            }
        )
    );

    if (result.hasException) {
      print("Login Error: ${result.exception.toString()}");
      return null;
    }

    final Map<String, dynamic>? data = result.data?["login"];

    if(data == null){
      print("Login Failed: No data returned.");
      return null;
    }

    final Map<String, dynamic> learnerData = data["user"];
    final String accessToken = data["accessToken"];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", accessToken);
    print("Token Saved: $accessToken");
    print("auth service $learnerData");

    return Learner.fromJson(learnerData);

  }

  // remove token
  void logoutLearner(BuildContext context) async {
    await GraphQLService.clearTokens();
    Navigator.pushReplacementNamed(context, "/login");
    print("User logged out.");
  }

  static void logoutParent(BuildContext context) async {
    await GraphQLService.clearTokens();
    Navigator.pushNamedAndRemoveUntil(context, "/intro", (route) => false);
    print("User logged out.");
  }

}