import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  static Future<GraphQLClient> getClient() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");

    final HttpLink httpLink = HttpLink("http://10.0.2.2:5500/graphql");

    final AuthLink authLink = AuthLink(
      getToken: () async => accessToken != null ? "Bearer $accessToken" : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }


  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.getString("accessToken");
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
  }

  static Future<bool> refreshToken(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");

    if (refreshToken == null) return false; // No refresh token, must log in

    final HttpLink httpLink = HttpLink("http://10.0.2.2:5500/graphql");

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    String refreshTokenMutation = role == "parent"
        ? """
          mutation RefreshTokenParent(\$refreshToken: String!) {
            refreshTokenParent(refreshToken: \$refreshToken) {
              accessToken
              refreshToken
            }
          }
        """
        : """
          mutation RefreshTokenUser(\$refreshToken: String!) {
            refreshTokenUser(refreshToken: \$refreshToken) {
              accessToken
              refreshToken
            }
          }
        """;
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(refreshTokenMutation),
        variables: {
          "refreshToken": refreshToken,
        },
      ),
    );

    if (result.hasException) return false; // Refresh failed

    final String newAccessToken = role == "parent"
        ? result.data?["refreshTokenParent"]?["accessToken"]
        : result.data?["refreshTokenUser"]?["accessToken"];

    final newRefreshToken = role == "parent"
        ? result.data?["refreshTokenParent"]?["refreshToken"]
        : result.data?["refreshTokenUser"]?["refreshToken"];

    if (newAccessToken != null && newRefreshToken != null) {
      await saveTokens(newAccessToken, newRefreshToken);
      return true;
    }


    return false;
  }

  static Future<QueryResult?> handleAuthErrors({
    required QueryResult result,
    required String role,
    required Future<QueryResult> Function() retryRequest, // Function to retry the request
  }) async {
    if (result.hasException) {
      bool isUnauthorized = result.exception!.graphqlErrors.any(
            (error) => error.message.contains("Unauthorized"),
      );

      if (isUnauthorized) {
        bool refreshed = await refreshToken(role); // Try refreshing token

        if (refreshed) {
          print("Token refreshed! Retrying request...");
          return await retryRequest(); // Retry the original request
        } else {
          print("Refresh failed! Logging out...");
          await GraphQLService.clearTokens();
          // Navigator.pushReplacementNamed(context, "/login");
        }
      }
    }
    return null; // Return null if no retry is needed
  }


}