import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  static Future<GraphQLClient> getClient() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    print("checkkkkkkkkk $accessToken");

    final HttpLink httpLink = HttpLink("http://192.168.1.2:5500/graphql");

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
    print("olddd token $refreshToken");
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    String refreshTokenMutation = role == "parent"
        ? """
          mutation refreshTokenParent(\$refreshToken: String!) {
            refreshTokenParent(refreshToken: \$refreshToken) {
              accessToken
              refreshToken
            }
          }
        """
        : """
          mutation refreshTokenUser(\$refreshToken: String!) {
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
    print(result);
    if (result.hasException) return false; // Refresh failed

    final String newAccessToken = role == "parent"
        ? result.data?["refreshTokenParent"]?["accessToken"]
        : result.data?["refreshTokenUser"]?["accessToken"];

    final newRefreshToken = role == "parent"
        ? result.data?["refreshTokenParent"]?["refreshToken"]
        : result.data?["refreshTokenUser"]?["refreshToken"];

    if (newAccessToken != null && newRefreshToken != null) {
      print("savedddddddddddddddd");
      await saveTokens(newAccessToken, newRefreshToken);
      return true;
    }

    return false;
  }

  static Future<QueryResult?> handleAuthErrors({
    required QueryResult result,
    required String role,
    required Future<QueryResult> Function() retryRequest,
  }) async {
    print("Handling authentication errors for the result: $result");

    if (result.hasException) {
      print("Exception found in result.");
      bool isUnauthorized = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.any(
            (error) => error.message.contains("Unauthorized"),
      )
          : result.exception!.linkException is ServerException &&
          result.exception!.linkException.toString().contains("Unauthorized");
      print(isUnauthorized);

      if (isUnauthorized) {
        print("Token appears to be invalid or expired. Attempting to refresh.");

        bool refreshed = await refreshToken(role);

        if (refreshed) {
          print("Token successfully refreshed! Retrying the original request...");
          final prefs = await SharedPreferences.getInstance();
          String? accessToken = prefs.getString("accessToken");
          String? refreshToken = prefs.getString("refreshToken");
          print("new access tokeennn $accessToken");
          print("new refresh tokeennn $refreshToken");

          return await retryRequest();
        } else {
          print("Token refresh failed! Logging out and clearing tokens...");
          await GraphQLService.clearTokens();
          return null;
        }
      }
    }

    return result;
  }



}