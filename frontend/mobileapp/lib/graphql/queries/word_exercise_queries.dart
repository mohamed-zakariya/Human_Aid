// exercise_queries.dart

const String startExerciseMutation = r'''
mutation StartExercise($userId: ID!, $exerciseId: ID!) {
  startExercise(userId: $userId, exerciseId: $exerciseId) {
    message
    startTime
  }
}
''';

const String endExerciseMutation = r'''
mutation EndExercise($userId: ID!, $exerciseId: ID!) {
  endExercise(userId: $userId, exerciseId: $exerciseId) {
    message
    timeSpent
  }
}
''';
