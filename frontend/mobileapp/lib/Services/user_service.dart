import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/models/parent.dart';
import 'package:mobileapp/models/learner.dart';

class UserService {
  static Future<Parent?> getParentById(String parentId) async {
    final client = await GraphQLService.getClient();

    const String query = r'''
      query getParentDataById($parentId: ID!) {
        getParentDataById(parentId: $parentId) {
          id,
          name,
          gender,
          email,
        }
      }
    ''';

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'parentId': parentId},
      ),
    );

    final QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "parent",
      retryRequest: () async {
        final retryClient = await GraphQLService.getClient();
        return await retryClient.query(
          QueryOptions(
            document: gql(query),
            variables: {'parentId': parentId},
          ),
        );
      },
    );

    if (finalResult == null || finalResult.hasException) {
      print("Get Parent Error: ${finalResult?.exception?.toString()}");
      return null;
    }

    final data = finalResult.data?["getParentDataById"];
    if (data == null) {
      print("No parent data found.");
      return null;
    }

    return Parent.fromJson(data);
  }

  static Future<Learner?> getLearnerById(String userId) async {
    final client = await GraphQLService.getClient();

    const String query = r'''
      mutation getLearnerDataById($userId: ID!) {
        getLearnerDataById(userId: $userId) {
          id
          name
          email
          role
          gender
          nationality
        }
      }
    ''';

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'userId': userId},
      ),
    );

    final QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "learner",
      retryRequest: () async {
        final retryClient = await GraphQLService.getClient();
        return await retryClient.query(
          QueryOptions(
            document: gql(query),
            variables: {'userId': userId},
          ),
        );
      },
    );

    if (finalResult == null || finalResult.hasException) {
      print("Get Learner Error: ${finalResult?.exception?.toString()}");
      return null;
    }

    final data = finalResult.data?["getLearnerDataById"];
    if (data == null) {
      print("No learner data found.");
      return null;
    }

    return Learner.fromJson(data);
  }
}
