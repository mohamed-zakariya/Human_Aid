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
type Exercise {
  id: ID!
  name: String!
  arabic_name: String!
  type: String!
  english_description:String!
  arabic_description:String!
  progress: Progress
  levels: [Level!]!
}
type Game {
  game_id: String!
  name: String!
  arabic_name: String!
}

type Level {
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

  extend type Query {
    users: [User!]
    checkUserUsernameExists(username: String!): UsernameCheckResponse!
    checkUserEmailExists(email: String!): EmailCheckResponse!
    learnerHomePage(userId: ID!): [Exercise!]!
    getLevelsForExercises: [Exercise!]!
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
`;
