import 'dart:io';
import 'package:http/io_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  static Future<GraphQLClient> getClient() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");

    // Create an IOClient with a custom HttpClient that has a bigger timeout.
    final customIOClient = IOClient(
      HttpClient()..connectionTimeout = const Duration(seconds: 30),
    );

    final HttpLink httpLink = HttpLink(
      "http://10.0.2.2:5500/graphql",
      httpClient: customIOClient, 
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => accessToken != null ? "Bearer $accessToken" : null,
    );

    // Combine auth and HTTP links
    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
