const String processSpeechMutation = r'''
  mutation wordsExercise($userId: ID!, $exerciseId: ID!, $wordId: ID!, $audioFile: Upload!) {
    wordsExercise(
      userId: $userId,
      exerciseId: $exerciseId,
      wordId: $wordId,
      audioFile: $audioFile
    ) {
      spokenWord
      expectedWord
      isCorrect
      message
    }
  }
''';