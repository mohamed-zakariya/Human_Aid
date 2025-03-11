export const wordsExerciseTypeDefs = `#graphql
scalar Upload

type ProcessedSpeech {
  spokenWord: String!
  expectedWord: String!
  isCorrect: Boolean!
  message: String!
}

type ExerciseSession {
  message: String!
  startTime: String
}

type ExerciseEnd {
  message: String!
  timeSpent: Int!
}

type Mutation {
  startExercise(userId: ID!, exerciseId: ID!): ExerciseSession!
  endExercise(userId: ID!, exerciseId: ID!): ExerciseEnd!
  wordsExercise(
    userId: ID!
    exerciseId: ID!
    wordId: ID!
    audioFile: Upload!
  ): ProcessedSpeech!
}
`;
