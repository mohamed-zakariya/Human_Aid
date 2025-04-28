// exercise_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/queries/word_exercise_queries.dart';

/// A service class that uses a GraphQLClient to call
/// startExercise and endExercise mutations.
class ExerciseService {
  final GraphQLClient client;

  ExerciseService({required this.client});

  /// Calls `startExercise` mutation
  Future<Map<String, dynamic>?> startExercise(String userId, String exerciseId) async {
    final options = MutationOptions(
      document: gql(startExerciseMutation),
      variables: {
        'userId': userId,
        'exerciseId': exerciseId,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      // Handle or log errors here
      print('startExercise error: ${result.exception}');
      return null;
    }

    return result.data?['startExercise'] as Map<String, dynamic>?;
  }

  /// Calls `endExercise` mutation
  Future<Map<String, dynamic>?> endExercise(String userId, String exerciseId) async {
    final options = MutationOptions(
      document: gql(endExerciseMutation),
      variables: {
        'userId': userId,
        'exerciseId': exerciseId,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      // Handle or log errors here
      print('endExercise error: ${result.exception}');
      return null;
    }

    return result.data?['endExercise'] as Map<String, dynamic>?;
  }
}
