export const parentTypeDefs = `#graphql

type Parent {
  id: ID!
  name: String!
  email: String!
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
  linkedChildren: [User!]
}

type LoginResponse {
  parent: Parent
  accessToken: String
  refreshToken: String
}

type LogoutResponse {
  message: String!
}

type ForgotPasswordResponse {
  message: String!
}

type VerifyOTPResponse {
  message: String!
  token: String
}

type ResetPasswordResponse {
  message: String!
}

type EmailCheckResponse {
  emailExists: Boolean!
}

type LearnerProgress {
  id: ID!
  progress: [Exercisesprogress]
}

type Exercisesprogress {
  user_id: ID!
  exercise_id: ID!
  total_time_spent: Int
  levels: [LevelProgress!]
}

type LevelProgress {
  level_id: ID!
  correct_items: [String!]
  incorrect_items: [String!]
  games: [GameProgress!]
}

type GameProgress {
  game_id: ID!
  scores: [Int!]!
}

type LearneroverallProgress {
  id: ID!
  progress: [UserOverallProgress!]!
}

type UserOverallProgress {
  user_id: ID!
  name: String
  username: String!
  progress_by_exercise: [ProgressByExercise]
  overall_stats: OverallStats
}

type ProgressByExercise {
  exercise_id: ID!
  stats: Stats
}

type Stats {
  total_correct: StatDetails!
  total_incorrect: StatDetails!
  total_items_attempted: Int!
  accuracy_percentage: Float!
  average_game_score: Float!
  time_spent_seconds: Int!
}

type StatDetails {
  count: Int!
  items: [String!]
}

type OverallStats {
  total_time_spent: Int!
  combined_accuracy: Float!
  average_score_all: Float!
}

type LearnerDailyAttempts {
  date: String!
  users: [UserDailyAttempt!]!
}

type UserDailyAttempt {
  user_id: ID!
  name: String
  username: String!
  correct_words: [WordAttempt]
  incorrect_words: [WordAttempt]
  correct_letters: [LetterAttempt]
  incorrect_letters: [LetterAttempt]
  correct_sentences: [SentenceAttempt]
  incorrect_sentences: [SentenceAttempt]
  game_attempts: [GameAttempt]
}

type WordAttempt {
  word_id: ID!
  correct_word: String!
  spoken_word: String!
}

type LetterAttempt {
  letter_id: ID!
  correct_letter: String!
  spoken_letter: String!
}

type SentenceAttempt {
  sentence_id: ID!
  correct_sentence: String!
  spoken_sentence: String!
}

type GameAttempt {
  game_id: ID!
  level_id: ID!
  game_name: String
  game_arabic_name: String
  level_arabic_name: String
  level_name: String
  attempts: [GameAttemptEntry!]!
}

type GameAttemptEntry {
  score: Int!
  timestamp: String
}

type UpdateParentProfileResponse {
  success: Boolean!
  message: String!
  updatedParent: Parent
}

extend type Query {
  parents: [Parent!]
  checkParentEmailExists(email: String!): EmailCheckResponse!
  getLearnerProgress(parentId: ID!): LearnerProgress
  getLearnerOverallProgress(parentId: ID!): LearneroverallProgress
  getParentChildren(parentId: ID!): [User!]
  getLearnerDailyAttempts(parentId: ID!): [LearnerDailyAttempts]
  parentProfile(parentId: ID!): Parent
}

extend type Mutation {
  loginParent(
    email: String!
    password: String!
  ): LoginResponse!

  signUpParent(
    parent: AddParentData
  ): LoginResponse!

  refreshTokenParent(
    refreshToken: String!
  ): LoginResponse!

  logout(
    refreshToken: String!
  ): LogoutResponse!

  forgotParentPassword(
    email: String!
  ): ForgotPasswordResponse!

  verifyParentOTP(
    email: String!
    otp: String!
  ): VerifyOTPResponse!

  resetParentPassword(
    token: String!
    newPassword: String!
  ): ResetPasswordResponse!

  updateParentProfile(input: UpdateParentProfileInput!): UpdateParentProfileResponse!
}

input AddParentData {
  name: String!
  email: String!
  password: String
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
}

input UpdateParentProfileInput {
  parentId: ID!
  name: String
  email: String
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
}
`;
