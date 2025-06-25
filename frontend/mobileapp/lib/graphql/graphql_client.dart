import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Custom HTTP client with timeout support
class TimeoutHttpClient extends http.BaseClient {
  final http.Client _inner;
  final Duration timeout;

  TimeoutHttpClient(this._inner, this.timeout);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _inner.send(request).timeout(timeout);
  }

  @override
  void close() {
    _inner.close();
  }
}

class GraphQLService {
// Default options for GraphQL operations (Updated for graphql_flutter 5.x+)
  static DefaultPolicies get defaultOptions => DefaultPolicies(
    watchQuery: Policies(
      fetch: FetchPolicy.cacheAndNetwork,
      error: ErrorPolicy.all,
    ),
    query: Policies(
      fetch: FetchPolicy.cacheAndNetwork,
      error: ErrorPolicy.all,
    ),
    mutate: Policies(
      fetch: FetchPolicy.networkOnly,
      error: ErrorPolicy.all,
    ),
  );


  static Future<GraphQLClient> getClient() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");

    // Create HTTP client with standard timeout
    final httpClient = TimeoutHttpClient(
      http.Client(),
      const Duration(seconds: 30),
    );

    final HttpLink httpLink = HttpLink(
      "https://human-aid-deployment.onrender.com/graphql",
      httpClient: httpClient,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => accessToken != null ? "Bearer $accessToken" : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: defaultOptions, // ✅ this now points to your getter that returns DefaultPolicies
    );
  }

  // Special client for long-running operations like story generation
  static Future<GraphQLClient> getLongRunningClient() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");

    // Create HTTP client with extended timeout for long operations
    final httpClient = TimeoutHttpClient(
      http.Client(),
      const Duration(minutes: 15), // Maximum timeout for HTTP layer
    );

    final HttpLink httpLink = HttpLink(
      "https://human-aid-deployment.onrender.com/graphql",
      httpClient: httpClient,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        'Keep-Alive': 'timeout=900, max=1000', // Keep connection alive for 15 minutes
      },
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => accessToken != null ? "Bearer $accessToken" : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: defaultOptions, // ✅ this now points to your getter that returns DefaultPolicies
    );
  }

  static Future<void> saveTokens(String accessToken, String refreshToken, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
    await prefs.setString("role", role);
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

    if (refreshToken == null) return false;

    try {
      final client = await getClient();

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
          variables: {"refreshToken": refreshToken},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Token refresh timeout', const Duration(seconds: 30));
        },
      );

      if (result.hasException) {
        print("Token refresh failed: ${result.exception}");
        return false;
      }

      final String? newAccessToken = role == "parent"
          ? result.data?["refreshTokenParent"]?["accessToken"]
          : result.data?["refreshTokenUser"]?["accessToken"];

      final String? newRefreshToken = role == "parent"
          ? result.data?["refreshTokenParent"]?["refreshToken"]
          : result.data?["refreshTokenUser"]?["refreshToken"];

      if (newAccessToken != null && newRefreshToken != null) {
        await saveTokens(newAccessToken, newRefreshToken, role!);
        print("Token refreshed successfully");
        return true;
      }

      return false;
    } catch (e) {
      print("Token refresh error: $e");
      return false;
    }
  }

  static Future<QueryResult?> handleAuthErrors({
    required QueryResult result,
    required String role,
    required Future<QueryResult> Function() retryRequest,
  }) async {
    print("Checking for auth errors in result: ${result.hasException}");

    if (result.hasException) {
      // Check for timeout errors first
      if (result.exception.toString().contains('TimeoutException') ||
          result.exception.toString().contains('timeout')) {
        print("Request timed out - not an auth error");
        return result; // Return the timeout error as-is
      }

      // Check for unauthorized errors
      bool isUnauthorized = false;

      if (result.exception!.graphqlErrors.isNotEmpty) {
        isUnauthorized = result.exception!.graphqlErrors.any(
              (error) => error.message.toLowerCase().contains("unauthorized") ||
              error.message.toLowerCase().contains("invalid token") ||
              error.message.toLowerCase().contains("expired"),
        );
      }

      if (result.exception!.linkException != null) {
        final linkExceptionStr = result.exception!.linkException.toString().toLowerCase();
        isUnauthorized = isUnauthorized ||
            linkExceptionStr.contains("unauthorized") ||
            linkExceptionStr.contains("401") ||
            linkExceptionStr.contains("invalid token");
      }

      if (isUnauthorized) {
        print("Unauthorized error detected. Attempting token refresh...");

        bool refreshed = await refreshToken(role);

        if (refreshed) {
          print("Token refreshed successfully. Retrying request...");
          try {
            return await retryRequest();
          } catch (e) {
            print("Retry request failed: $e");
            return null;
          }
        } else {
          print("Token refresh failed. Clearing tokens...");
          await clearTokens();
          return null;
        }
      }
    }

    return result;
  }

  // Enhanced mutation execution with progressive timeout strategy
  static Future<QueryResult> executeWithProgressiveTimeout({
    required GraphQLClient client,
    required MutationOptions options,
    List<Duration> timeoutStages = const [
      Duration(seconds: 45),   // First attempt: 45 seconds
      Duration(minutes: 3),    // Second attempt: 3 minutes
      Duration(minutes: 8),    // Third attempt: 8 minutes
      Duration(minutes: 15),   // Final attempt: 15 minutes
    ],
  }) async {
    Exception? lastException;

    for (int i = 0; i < timeoutStages.length; i++) {
      final timeout = timeoutStages[i];
      print("Attempting mutation with ${timeout.inSeconds}s timeout (attempt ${i + 1}/${timeoutStages.length})");

      try {
        final completer = Completer<QueryResult>();
        Timer? timeoutTimer;

        // Start the mutation
        final mutationFuture = client.mutate(options);

        // Set up timeout
        timeoutTimer = Timer(timeout, () {
          if (!completer.isCompleted) {
            completer.completeError(
              TimeoutException(
                'GraphQL mutation timed out after ${timeout.inSeconds} seconds',
                timeout,
              ),
            );
          }
        });

        // Wait for either completion or timeout
        mutationFuture.then((result) {
          timeoutTimer?.cancel();
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        }).catchError((error) {
          timeoutTimer?.cancel();
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });

        final result = await completer.future;
        return result;

      } on TimeoutException catch (e) {
        lastException = e;
        print("Attempt ${i + 1} timed out after ${timeout.inSeconds}s");

        // If this isn't the last attempt, wait before retrying
        if (i < timeoutStages.length - 1) {
          final waitTime = Duration(seconds: 5 + (5 * i)); // Progressive wait: 5s, 10s, 15s
          print("Waiting ${waitTime.inSeconds}s before next attempt...");
          await Future.delayed(waitTime);
        }
      } catch (e) {
        // Non-timeout error, return immediately
        print("Non-timeout error occurred: $e");
        rethrow;
      }
    }

    // All attempts failed with timeout
    throw lastException ?? TimeoutException('All timeout attempts failed', timeoutStages.last);
  }
}