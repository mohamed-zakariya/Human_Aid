export const wordsExerciseTypeDefs = `#graphql
scalar Upload

type ProcessedSpeech {
  spokenWord: String!
  expectedWord: String!
  isCorrect: Boolean!
  message: String!
  score: Int
  accuracy: Float
}

type Word {
  _id: ID!
  word: String!
  level: String!
  synonym: String
  imageUrl: String
}

type ExerciseSession {
  message: String!
  startTime: String
}

type ExerciseEnd {
  message: String!
  timeSpent: Int!
}

type Query {
  getWordsByLevel(level: String!): [Words]
  getWordForExercise(userId: ID!, exerciseId: ID!, level: String!): [Word]
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

  updateUserProgress(
    userId: ID!
    exerciseId: ID!
    wordId: ID!
    levelId: ID!
    audioFile: String
    spokenWord: String!
  ): ProcessedSpeech!
}
`;
