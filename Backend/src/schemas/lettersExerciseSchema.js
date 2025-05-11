export const lettersExerciseTypeDefs = `#graphql
scalar Upload

type ProcessedLetter {
  spokenLetter: String!
  expectedLetter: String!
  isCorrect: Boolean!
  message: String!
  score: Int
  accuracy: Float
}

type FormExample {
  form: String!
  example: String!
}

type LetterForms {
  isolated: [FormExample!]!   
  connected: [FormExample!]!  
  final: [FormExample!]!      
}


type Letter {
  _id: ID!
  letter: String!
  color: String!
  group: String!
  forms: LetterForms!
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
  getLettersForExercise: [Letter!]!
}

type Mutation {
  startExercise(userId: ID!, exerciseId: ID!): ExerciseSession!
  endExercise(userId: ID!, exerciseId: ID!): ExerciseEnd!

  updateLetterProgress(
    userId: ID!
    exerciseId: ID!
    levelId: ID!
    letterId: ID!
    audioFile: Upload!
    spokenLetter: String!
  ): ProcessedLetter!
}
`;
