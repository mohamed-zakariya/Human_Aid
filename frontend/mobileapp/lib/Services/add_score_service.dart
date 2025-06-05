import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql/graphql_client.dart';
import '../graphql/queries/score_update_query.dart';

class AddScoreService {
  static Future<void> updateScore({
    required int score,
    required int outOf,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    final exerciseId = prefs.getString("exerciseId");
    final levelId = prefs.getString("levelId");
    final gameId = prefs.getString("gameId");

    if ([userId, exerciseId, levelId, gameId].contains(null)) {
      print("❌ One or more IDs are missing in local storage.");
      return;
    }

    // 🔢 Scale score to be out of 10
    final scaledScore = ((score / outOf) * 10).round();

    final client = await GraphQLService.getClient();

    final MutationOptions options = MutationOptions(
      document: gql(updateSocreMutation),
      variables: {
        "userId": userId,
        "exerciseId": exerciseId,
        "levelId": levelId,
        "gameId": gameId,
        "score": scaledScore,
      },
    );

    final result = await client.mutate(options);
    final finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "learner",
      retryRequest: () async {
        final newClient = await GraphQLService.getClient();
        return await newClient.mutate(options);
      },
    );

    if (finalResult != null) {
      if (finalResult.hasException) {
        print("Mutation Error: ${finalResult.exception.toString()}");
      } else {
        final response = finalResult.data?['updategamesProgress'];
        print("✅ Score submitted: ${response?['message']} (scaled: $scaledScore)");
      }
    } else {
      print("❌ Failed to send score even after retry.");
    }
  }
}
