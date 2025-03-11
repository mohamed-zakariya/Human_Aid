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
