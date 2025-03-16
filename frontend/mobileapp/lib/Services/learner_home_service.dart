// Services/learner_home_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries/learner_home_query.dart';
import '../graphql/graphql_client.dart';

class LearnerHomeService {
  /// Fetch exercises for the Learner Home Page.
  /// Returns a `List<Map<String, dynamic>>` that you can parse further.
  static Future<List<Map<String, dynamic>>> fetchLearnerHomeData(String userId) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      final QueryOptions options = QueryOptions(
        document: gql(getLearnerHomePageQuery),
        variables: {
          'userId': userId,
        },
      );

      final QueryResult result = await client.query(options);

      // Handle possible token expiration/unauthorized here, if you want:
      // (But you already have `handleAuthErrors` in `GraphQLService`.)
      // final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
      //   result: result,
      //   role: "childOrParent", // adapt this if needed
      //   retryRequest: () => client.query(options),
      // );
      // if (handledResult == null) {
      //   return [];
      // }

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // result.data["learnerHomePage"] is the array of exercises
      final data = result.data?['learnerHomePage'];
      if (data == null) {
        return [];
      }

      // Safely cast to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }
}
