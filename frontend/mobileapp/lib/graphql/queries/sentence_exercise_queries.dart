/// GraphQL strings – keep them central so services/screens can import one file
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
  $sentence_id: ID!,
  $sentence_text: String!,
  $spoken_sentence: String!,
  $is_correct: Boolean!,
  $incorrect_words: [IncorrectWordInput!]
) {
  updateSentenceProgress(
    userId: $userId,
    exerciseId: $exerciseId,
    sentence_id: $sentence_id,
    sentence_text: $sentence_text,
    spoken_sentence: $spoken_sentence,
    is_correct: $is_correct,
    incorrect_words: $incorrect_words
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
