const String processSpeechMutation = r'''
  mutation ProcessSpeech($userId: ID!, $exerciseId: ID!, $wordId: ID!, $audioFile: Upload!) {
    processSpeech(
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