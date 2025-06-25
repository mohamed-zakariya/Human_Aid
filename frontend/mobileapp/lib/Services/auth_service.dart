import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/auth_login_query.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/parent.dart';


import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/queries/check_exists_query.dart';

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


    GraphQLService.saveTokens(accessToken, refreshToken, "parent");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", parentData["id"] ?? "");


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
    final String refreshToken = data["refreshToken"];


    GraphQLService.saveTokens(accessToken, refreshToken, "learner");

    print("Token Saved: $accessToken");
    print("auth service $learnerData");


    

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", learnerData["id"] ?? "");

    print("Stored userId: ${learnerData["id"]}");

  return Learner.fromJson(learnerData);
}

  static Future<bool> usernameLearnerCheck(
      String username
      ) async{

    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(checkUserUsernameExists),
            variables: {
              "username": username
            }
        )
    );

    if (result.hasException) {
      print("username exist Error: ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["checkUserUsernameExists"];

    if(data == null){
      return false;
    }


    return data["usernameExists"];
    // return Parent.fromJson(userdata, accessToken, refreshToken);

  }

  static Future<bool> emailParentCheck(
      String email
      ) async{

    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(checkParentEmailExists),
            variables: {
              "email": email
            }
        )
    );

    if (result.hasException) {
      print("email exist Error: ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["checkParentEmailExists"];

    if(data == null){
      return false;
    }


    return data["emailExists"];
    // return Parent.fromJson(userdata, accessToken, refreshToken);

  }

  static Future<bool> emailLearnerCheck(
      String email
      ) async{

    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(checkParentEmailExists),
            variables: {
              "email": email
            }
        )
    );

    if (result.hasException) {
      print("email exist Error:  ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["checkParentEmailExists"];

    if(data == null){
      return false;
    }


    return data["emailExists"];
    // return Parent.fromJson(userdata, accessToken, refreshToken);

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