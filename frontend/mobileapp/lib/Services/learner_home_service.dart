// Services/learner_home_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries/learner_home_query.dart';
import '../graphql/graphql_client.dart';

class LearnerHomeService {
  /// Fetch exercises for the Learner Home Page.
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

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data?['learnerHomePage'];
      if (data == null) {
        return [];
      }

      // No change needed here, just ensure the new fields are available in the returned data
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }
}
