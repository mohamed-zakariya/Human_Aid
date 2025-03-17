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

  type LearnerDailyAttempts {
    date: String!
    correct_words: [WordAttempt!]!
    incorrect_words: [WordAttempt!]!
}

type WordAttempt {
    word_id: ID!
    spoken_word: String!
}


extend type Query {
    parents: [Parent!]
    checkParentEmailExists(email: String!): EmailCheckResponse!
    getLearnerProgress(parentId: ID!): LearnerProgress
    getParentChildren(parentId: ID!): [User!]
    getLearnerDailyAttempts(parentId: ID!): [LearnerDailyAttempts!]!
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
`;


