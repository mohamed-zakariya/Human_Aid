// lib/services/level_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../models/level.dart';

class LevelService {
  /// Re-use the query string in one place so it never drifts
  // lib/services/level_service.dart  (only the query string is different)
  static const String _levelsQuery = r'''
    query GetLevelsForExercises {
      getLevelsForExercises {
        id
        name
        arabic_name
        levels {
          level_id
          level_number
          name
          arabic_name
          games {
            game_id
            name
            arabic_name
          }
        }
      }
    }
  ''';

  /// Public API – returns only the levels for the requested exercise
  static Future<List<Level>> getLevelsForExercise(String exerciseId) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      // ---- 1. run the plural-field query (no variables) --------------------
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(_levelsQuery),
        ),
      );

      // ---- 2. handle auth errors & retry once if token gets refreshed -----
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: 'user',                  // adjust role if needed
        retryRequest: () => _runQuery(client),
      );

      if (handledResult == null || handledResult.hasException) {
        throw Exception(
          handledResult?.exception?.toString() ??
              'Failed to fetch levels',
        );
      }

      // ---- 3. pick the exercise we care about -----------------------------
      final List exercises =
          handledResult.data?['getLevelsForExercises'] ?? [];

      final Map? exercise = exercises.firstWhere(
        (e) => e['id'] == exerciseId,
        orElse: () => null,
      );

      if (exercise == null) {
        throw Exception('Exercise $exerciseId not found');
      }

      final List levelsData = exercise['levels'] as List;

      return levelsData
          .map<Level>((levelData) => Level.fromJson(levelData))
          .toList();
    } catch (e) {
      print('Error fetching levels: $e');
      return [];
    }
  }

  /// Internal helper so handleAuthErrors can retry the same request
  static Future<QueryResult> _runQuery(GraphQLClient client) {
    return client.query(
      QueryOptions(
        document: gql(_levelsQuery),
      ),
    );
  }
}
