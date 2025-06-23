export const userTypeDefs = `#graphql
  type User {
    id: ID!
    name: String
    username: String!
    email: String
    phoneNumber: String
    nationality: String
    birthdate: String!
    gender: String!
    role: String!
    currentStage: String
    lastActiveDate: String
}
type LearnerProfile {
  name: String!
  username: String!
  email: String
  nationality: String!
  birthdate: String!
  gender: String!
  parentName: String
  totalTimeSpent: Int!
}
type Exercise {
  id: ID!
  name: String!
  arabic_name: String!
  type: String!
  english_description:String!
  arabic_description:String!
  progress: ExerciseStats
  levels: [Level!]!
  progress_imageUrl: String
  exercise_imageUrl: String
}
type Game {
  _id: ID!
  game_id: String!
  name: String!
  arabic_name: String!
}
type OverallProgress {
  combinedAccuracy: Float!
  averageScoreAll: Float!
  totalTimeSpent: Int!
}
type ExerciseStats {
  exerciseId: ID!
  accuracyPercentage: Float!
  score: Float!
  timeSpentSeconds: Int!
}
type Level {
  _id: ID!
  level_id: String!
  level_number: Int!
  name: String!
  arabic_name: String!
  games: [Game!]!
}

type Progress {
  accuracyPercentage: Float!
  score: Int!
}


type signUpChildResponse{
    parentId: ID!
    child: User
}

type signUpAdultdResponse{
    adult: User
    refreshToken: String
    accessToken: String
}

  type LoginResponse {
    user:User
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
    token: String!
  }

  type ResetPasswordResponse {
    message: String!
  }

  type UsernameCheckResponse {
    usernameExists: Boolean!
}
  type EmailCheckResponse {
    emailExists: Boolean!
  }

  type DeleteChildResponse {
  success: Boolean!
  message: String!
  }

  type UpdateProfileResponse {
  success: Boolean!
  message: String!
  updatedUser: User
}

  extend type Query {
    users: [User!]
    checkUserUsernameExists(username: String!): UsernameCheckResponse!
    checkUserEmailExists(email: String!): EmailCheckResponse!
    learnerHomePage(userId: ID!): [Exercise!]!
    getLevelsForExercises: [Exercise!]!
    learnerProfile(userId: ID!): LearnerProfile!
    # getLearnerDataById(userId: ID!): User!
    
    
  }

  extend type Mutation {
    login(
      username: String!
      password: String!
    ): LoginResponse!

    signUpAdult(
      adult: AddAdultData
    ): signUpAdultdResponse!

    signUpChild(
        child: AddChildData
    ): signUpChildResponse!

    deleteChild(
      parentId: String!,
      passwordParent: String!,
      usernameChild: String!
    ): DeleteChildResponse

    refreshTokenUser(
      refreshToken: String!
    ): LoginResponse!

    logout(
      refreshToken: String!
    ): LogoutResponse!

    forgotUserPassword(
      email: String!
    ): ForgotPasswordResponse!

    verifyUserOTP(
      email: String!
      otp: String!
    ): VerifyOTPResponse!

    resetUserPassword(
      token: String!
      newPassword: String!
    ): ResetPasswordResponse!

    updateUserProfile(input: UpdateUserProfileInput!): UpdateProfileResponse!

    getLearnerDataById(userId: ID!): User!
  }
  input AddChildData{
    parentId: ID!
    name: String!
    username: String!
    password: String!
    nationality: String!
    birthdate: String!
    gender: String!
    role: String!
}
  input AddAdultData{
    name: String!
    username: String!
    email: String!
    phoneNumber: String
    password: String!
    nationality: String!
    birthdate: String!
    gender: String!
    role: String!
  }
  input UpdateUserProfileInput {
  userId: ID!
  name: String
  username: String
  email: String
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
  currentStage: String
}
`;
