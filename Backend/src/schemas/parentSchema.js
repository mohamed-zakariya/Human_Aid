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

extend type Query {
    parents: [Parent!]
    checkParentEmailExists(email: String!): EmailCheckResponse!
    getParentChildren(parentId: ID!): [User!]
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
input AddParentData{
  name: String!
  email: String!
  password: String
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
}
`;