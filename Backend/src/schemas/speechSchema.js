
export const speechTypeDefs = `#graphql
scalar Upload
  type ProcessedSpeech {
    spokenWord: String!
    expectedWord: String!
    isCorrect: Boolean!
    message: String!
  }
  type Mutation {
    processSpeech(
      userId: ID!
      exerciseId: ID!
      wordId: ID!
      audioFile: Upload!
    ): ProcessedSpeech!
  }
`;