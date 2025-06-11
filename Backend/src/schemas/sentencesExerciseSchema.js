export const sentencesExerciseTypeDefs = `#graphql
scalar Upload

type Sentence {
  _id: ID!
  sentence: String!
  level: String!
}

input IncorrectWordInput {
  incorrect_word: String!
  frequency: Int!
  sentence_context: String!
}

type ExerciseSession {
  message: String!
  startTime: String
}

type ExerciseEnd {
  message: String!
  timeSpent: Int!
}

type ProcessedSentence {
  spokenSentence: String!
  expectedSentence: String!
  isCorrect: Boolean!
  message: String!
  score: Int
  accuracy: Float
}

type OverallProgress {
  user_id: ID!
  progress_id: ID!
  completed_exercises: [ID!]
  total_time_spent: Int!
  average_accuracy: Float!
  total_correct_sentences: [String!]
  total_incorrect_sentences: [String!]
}

type UserDailyAttempts {
  user_id: ID!
  exercise_id: ID!
  date: String!
  sentences_attempts: [SentenceAttempt]
  words_attempts: [String]
}

type SentenceAttempt {
  sentence_id: ID!
  spoken_sentence: String!
  is_correct: Boolean!
  attempts_number: Int!
  incorrect_words: [IncorrectWord]
}

type Query {
  getSentenceForExercise(level: String!): [Sentence]
}

type Mutation {
  startExercise(userId: ID!, exerciseId: ID!): ExerciseSession!
  endExercise(userId: ID!, exerciseId: ID!): ExerciseEnd!

  updateSentenceProgress(
    userId: ID!
    exerciseId: ID!
    levelId: ID! # Added levelId to match the updated implementation
    sentenceId: ID! # Renamed to match the function parameter
    audioFile: String
    spokenSentence: String! # Updated to match the spoken sentence input
    timeSpent: Int # Optional time spent parameter
  ): ProcessedSentence!
}
`;