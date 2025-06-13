import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/signup_query.dart';
import 'package:mobileapp/models/parent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learner.dart';

class SignupService {
  static Future<Parent?> signupParent(
    String name,
    String email,
    String password,
    String phoneNumber,
    String nationality,
    String birthdate,
    String gender
      ) async{

    final client = await GraphQLService.getClient();

    final QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(signupParentQuery),
            variables: {
              "parent": {
                "name": name,
                "email": email,
                "password": password,
                "phoneNumber": phoneNumber,
                "nationality": nationality,
                "birthdate": birthdate,
                "gender": gender
              }
            }
        )
    );


    //   // Handle auth errors & retry if needed
    //   QueryResult? finalResult = await GraphQLService.handleAuthErrors(
    //     result: result,
    //     context: context,
    //     role: userRole,
    //     retryRequest: () async => await client.query( // This function retries the same request
    //       QueryOptions(
    //         document: gql(myQuery),
    //         variables: myVariables,
    //       ),
    //     ),
    //   );
    //
    // // Use finalResult instead of result
    //   if (finalResult != null && !finalResult.hasException) {
    //     // Process successful response
    //   } else {
    //     print("Request still failed even after retry.");
    //   }


    if (result.hasException) {
      print("Signup Error: ${result.exception.toString()}");
      return null;
    }

    final Map<String, dynamic>? data = result.data?["signUpParent"];

    if(data == null){
      print("signup Failed: No data returned.");
      return null;
    }

    final Map<String, dynamic> userdata = data["parent"];
    final String accessToken = data["accessToken"];
    final String refreshToken = data["refreshToken"];

    GraphQLService.saveTokens(accessToken, refreshToken, "parent");

    return Parent.fromJson(userdata);
    // return Parent.fromJson(userdata, accessToken, refreshToken);

  }
  static Future<Learner?> signupChild(
      String parentId,
      String name,
      String username,
      String password,
      String nationality,
      String birthdate,
      String gender,
      String role
      ) async{

    final client = await GraphQLService.getClient();

    print("entered");
    print(username);
    final QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(signupChildQuery),
            variables: {
              "child": {
                "parentId": parentId,
                "name": name,
                "username": username,
                "password": password,
                "nationality": nationality,
                "birthdate": birthdate,
                "gender": gender,
                "role": role
              },
            }
        )
    );

    if (result.hasException) {
      print("Signup for child Error: ${result.exception.toString()}");
      return null;
    }

    final Map<String, dynamic>? data = result.data?["signUpChild"];

    if (data == null || data["child"] == null || data["parentId"] == null) {
      print("Signup Failed: Invalid data received.");
      return null;
    }


    final Map<String, dynamic> childData = data;

    print("account created $childData");
    print(childData["parentId"]);

    return Learner.fromJson(childData["child"], childData["parentId"]);

  }


  static Future<Learner?> signupAdult(
      String name,
      String username,
      String email,
      String password,
      String nationality,
      String birthdate,
      String gender,
      String role
      ) async{

    final client = await GraphQLService.getClient();

    print("entered");
    print(username);
    final QueryResult result = await client.query(
        QueryOptions(
            document: gql(signupAdultQuery),
            variables: {
              "adult": {
                "name": name,
                "username": username,
                "email": email,
                "password": password,
                "nationality": nationality,
                "birthdate": birthdate,
                "gender": gender,
                "role": role
              },
            }
        )
    );

    if (result.hasException) {
      print("Signup for adult Error: ${result.exception.toString()}");
      return null;
    }

    final Map<String, dynamic>? data = result.data?["signUpAdult"];

    if (data == null || data["adult"] == null || data["accessToken"] == null) {
      print("Signup Failed: Invalid data received.");
      return null;
    }


    final Map<String, dynamic> learnerData = data;

    print("account created $learnerData");
    print(learnerData["accessToken"]);

    return Learner.fromJson(learnerData["adult"]);

  }
}