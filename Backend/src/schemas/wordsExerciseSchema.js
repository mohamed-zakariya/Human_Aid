
export const wordsExerciseTypeDefs = `#graphql
scalar Upload
  type ProcessedSpeech {
    spokenWord: String!
    expectedWord: String!
    isCorrect: Boolean!
    message: String!
  }
  type Mutation {
    wordsExercise(
      userId: ID!
      exerciseId: ID!
      wordId: ID!
      audioFile: Upload!
    ): ProcessedSpeech!
  }
`;