const String updateUserProgressMutation = r'''
mutation UpdateUserProgress(
  $userId: ID!,
  $exerciseId: ID!,
  $wordId: ID!,
  $audioFile: String,
  $spokenWord: String!
) {
  updateUserProgress(
    userId: $userId,
    exerciseId: $exerciseId,
    wordId: $wordId,
    audioFile: $audioFile,
    spokenWord: $spokenWord
  ) {
    spokenWord
    expectedWord
    isCorrect
    message
    score
    accuracy
  }
}
''';