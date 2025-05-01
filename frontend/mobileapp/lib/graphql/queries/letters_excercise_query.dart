const String startExerciseMutation = r'''
mutation StartExercise($userId:ID!,$exerciseId:ID!){
  startExercise(userId:$userId,exerciseId:$exerciseId){
    message
    startTime
  }
}''';

const String endExerciseMutation = r'''
mutation EndExercise($userId:ID!,$exerciseId:ID!){
  endExercise(userId:$userId,exerciseId:$exerciseId){
    message
    timeSpent
  }
}''';

const String updateLetterProgressMutation = r'''
mutation UpdateLetterProgress(
 $userId:ID!,
 $exerciseId:ID!,
 $letterId:ID!,
 $audioFile:Upload!,
 $spokenLetter:String!
){
  updateLetterProgress(
    userId:$userId,
    exerciseId:$exerciseId,
    letterId:$letterId,
    audioFile:$audioFile,
    spokenLetter:$spokenLetter){
      spokenLetter
      expectedLetter
      isCorrect
      message
      score
      accuracy
  }
}''';
