import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'package:mobileapp/graphql/queries/delete_learner_query.dart';
import 'package:mobileapp/graphql/queries/get_children_data.dart';
import 'package:mobileapp/models/learner.dart';

class ParentService {


  static Future<List<Learner?>?> getChildrenData(String? parentId) async {
    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(getChildrenDataQuery),
        variables: {"parentId": parentId},
      ),
    );


    if (result.hasException) {
      print("Login Error: ${result.exception.toString()}");
      return null;
    }

    final List<dynamic>? rawData = result.data?["getParentChildren"];

    if (rawData == null) {
      print("Login Failed: No data returned.");
      return null;
    }

    final List<Learner> data = rawData.map((item) => Learner.fromJson(item)).toList();


    return data;
  }

  static Future<bool> deleteLearner(String? parentId, String? passwordParent, String? usernameChild) async {
    final client = await GraphQLService.getClient();

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(deleteLearnerQuery),
        variables: {
          "parentId": parentId,
          "passwordParent": passwordParent,
          "usernameChild": usernameChild
        },
      ),
    );


    if (result.hasException) {
      print("Login Error: ${result.exception.toString()}");
      return false;
    }

    final Map<String, dynamic>? data = result.data?["deleteChild"];

    if (data == null) {
      print("Login Failed: No data returned.");
      return false;
    }
    print("delete userrrrrrrrrr ${data["success"]}");
    // bool finalResult = data["success"];
    return data["success"];
  }

}