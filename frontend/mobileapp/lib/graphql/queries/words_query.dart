// graphql/queries/words_query.dart
const String fetchWordsQuery = r'''
  query getWordForExercise($userId: ID!, $level: String!, $exerciseId: ID!) {
    getWordForExercise(userId: $userId, level: $level, exerciseId: $exerciseId) {
      _id
      word
      level
    }
  }
''';




const String getCorrectWordsbyId = """

query getLearntWordsbyId(\$userId: ID!){
  getLearntWordsbyId(userId: \$userId){
    correct_words
    incorrect_words {
      word_id
      incorrect_word
      frequency
    }
  }
}
""";