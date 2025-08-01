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

type AuthPayload {
    user: User
    accessToken: String!
    refreshToken: String!
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
    id: ID!
    name: String!
    username: String!
    email: String
    phoneNumber: String
    nationality: String!
    birthdate: String!
    accessToken: String
    refreshToken: String
    role: String!
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

  extend type Query {
    users: [User!]
    checkUserUsernameExists(username: String!): UsernameCheckResponse!
  }

  extend type Mutation {
    login(
      username: String!
      password: String!
    ): LoginResponse!

    googleLogin(
      idToken: String!
    ): AuthPayload!

    signUpAdult(
      adult: AddAdultData
    ): signUpAdultdResponse!

    signUpChild(
        child: AddChildData
    ): signUpChildResponse!

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
