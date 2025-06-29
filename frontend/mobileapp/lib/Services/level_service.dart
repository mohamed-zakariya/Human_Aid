// lib/services/level_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../models/level.dart';

class LevelService {
  /// Updated query string to include user parameters for unlocked games
  static const String _levelsQuery = r'''
    query GetLevelsForExercises($userId: ID!, $exerciseId: ID!) {
        getLevelsForExercises(userId: $userId, exerciseId: $exerciseId) {
          id
          name
          arabic_name
          exercise_imageUrl
          levels {
            _id
            level_id
            level_number
            name
            arabic_name
            games {
              _id
              game_id
              name
              arabic_name
              unlocked
            }
          }
        }
      }
  ''';

  /// Public API – returns only the levels for the requested exercise with user-specific unlocked status
  static Future<List<Level>> getLevelsForExercise(String exerciseId, String userId) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();

      // ---- 1. run the query with user and exercise parameters --------------------
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(_levelsQuery),
          variables: {
            'userId': userId,
            'exerciseId': exerciseId,
          },
        ),
      );

      // ---- 2. handle auth errors & retry once if token gets refreshed -----
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: 'user',                  // adjust role if needed
        retryRequest: () => _runQuery(client, userId, exerciseId),
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

  /// Returns both the levels for the requested exercise and the exercise object itself with user-specific data
  static Future<Map<String, dynamic>> getLevelsAndExercise(String exerciseId, String userId) async {
    try {
      final GraphQLClient client = await GraphQLService.getClient();
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(_levelsQuery),
          variables: {
            'userId': userId,
            'exerciseId': exerciseId,
          },
        ),
      );
      final QueryResult? handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: 'user',
        retryRequest: () => _runQuery(client, userId, exerciseId),
      );
      if (handledResult == null || handledResult.hasException) {
        throw Exception(
          handledResult?.exception?.toString() ?? 'Failed to fetch levels',
        );
      }
      final List exercises = handledResult.data?['getLevelsForExercises'] ?? [];
      final Map? exercise = exercises.firstWhere(
        (e) => e['id'] == exerciseId,
        orElse: () => null,
      );
      if (exercise == null) {
        throw Exception('Exercise $exerciseId not found');
      }
      final List levelsData = exercise['levels'] as List;
      final List<Level> levels = levelsData.map<Level>((levelData) => Level.fromJson(levelData)).toList();
      return {
        'levels': levels,
        'exercise': exercise,
      };
    } catch (e) {
      print('Error fetching levels and exercise: $e');
      return {
        'levels': <Level>[],
        'exercise': null,
      };
    }
  }

  /// Internal helper so handleAuthErrors can retry the same request
  static Future<QueryResult> _runQuery(GraphQLClient client, String userId, String exerciseId) {
    return client.query(
      QueryOptions(
        document: gql(_levelsQuery),
        variables: {
          'userId': userId,
          'exerciseId': exerciseId,
        },
      ),
    );
  }
}