export const parentTypeDefs = `#graphql

type Parent {
    id: ID!
    name: String!
    username: String
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

extend type Query {
    parents: [Parent!]
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

}
input AddParentData{
  name: String!
  username: String
  email: String!
  password: String
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
}

`;