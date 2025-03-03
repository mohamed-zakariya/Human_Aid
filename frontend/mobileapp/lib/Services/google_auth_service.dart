import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/google_login_query.dart';
import 'package:mobileapp/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "945135521967-cemm5lhipph0oploa7b57u9ak7jjl6t2.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
    forceCodeForRefreshToken: true,
  );

  static Future<User?> loginWithGoogle() async {
    try {
      print("🔹 Initiating Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("🔴 Google Sign-In Cancelled by user.");
        return null;
      }

      print("✅ Google User: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        print("🔴 Google Auth Error: ID Token is null.");
        return null;
      }

      final String idToken = googleAuth.idToken!;
      print("🔹 Google ID Token Received: $idToken");

      // Send ID Token to backend via GraphQL
      final GraphQLClient client = await GraphQLService.getClient();

      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(googleLoginMutation),
          variables: {'idToken': idToken},
        ),
      );

      if (result.hasException) {
        print("🔴 GraphQL Error: ${result.exception.toString()}");
        return null;
      }

      final Map<String, dynamic>? data = result.data?['googleLogin'];

      if (data == null) {
        print("🔴 Google Login Failed: No data returned.");
        return null;
      }

      final Map<String, dynamic>? userdata = data["user"];
      final String? accessToken = data["accessToken"];
      final String? refreshToken = data["refreshToken"];

      if (userdata == null || accessToken == null || refreshToken == null) {
        print("🔴 Google Login Failed: Missing required fields.");
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", accessToken);
      await prefs.setString("refreshToken", refreshToken);
      print("✅ Google Access Token Saved: $accessToken");

      return User.fromJson(userdata, accessToken);
    } catch (e, stackTrace) {
      print("🔴 Google Sign-In Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      log("🔴 Exception Details: $e", error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
