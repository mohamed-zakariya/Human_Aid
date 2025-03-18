// graphql/queries/words_query.dart
const String fetchWordsQuery = r'''
  query getWordForExercise($level: String!) {
    getWordForExercise(level: $level) {
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