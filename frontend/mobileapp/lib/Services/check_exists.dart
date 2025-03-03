import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/signup_query.dart';
import 'package:mobileapp/models/parent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/queries/check_exists_query.dart';
import '../models/learner.dart';

class CheckExists {
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
            document: gql(checkUserEmailExists),
            variables: {
              "email": email
            }
        )
    );

    if (result.hasException) {
      print("email exist Error: ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["checkUserEmailExists"];

    if(data == null){
      return false;
    }


    return data["emailExists"];
    // return Parent.fromJson(userdata, accessToken, refreshToken);

  }

}