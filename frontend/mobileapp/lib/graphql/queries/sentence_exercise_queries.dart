/// GraphQL strings for sentence exercises – updated to match backend schema
const String getSentencesQuery = r'''
query GetSentenceForExercise($level: String!) {
  getSentenceForExercise(level: $level) {
    _id
    sentence
    level
  }
}
''';

const String startExerciseMutation = r'''
mutation StartExercise($userId: ID!, $exerciseId: ID!) {
  startExercise(userId: $userId, exerciseId: $exerciseId) {
    message
    startTime
  }
}
''';

const String updateSentenceProgressMutation = r'''
mutation UpdateSentenceProgress(
  $userId: ID!,
  $exerciseId: ID!,
  $levelId: ID!,
  $sentenceId: ID!,
  $audioFile: String,
  $spokenSentence: String!,
  $timeSpent: Int
) {
  updateSentenceProgress(
    userId: $userId,
    exerciseId: $exerciseId,
    levelId: $levelId,
    sentenceId: $sentenceId,
    audioFile: $audioFile,
    spokenSentence: $spokenSentence,
    timeSpent: $timeSpent
  ) {
    spokenSentence
    expectedSentence
    isCorrect
    message
    score
    accuracy
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