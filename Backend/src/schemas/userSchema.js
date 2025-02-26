export const userTypeDefs = `#graphql

type User {
    id: ID!
    name: String!
    username: String!
    email: String
    phoneNumber: String
    nationality: String!
    birthdate: String!
    gender: String!
    role: String!
    currentStage: String
    lastActiveDate: String!
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

extend type Query {
    users: [User!]
}

extend type Mutation {
    login(
        username: String!
        password: String!
    ): LoginResponse!

    signUpAdult(
        name: String!
        username: String!
        email: String!
        password: String!
        phoneNumber: String
        nationality: String!
        birthdate: String!
        gender: String!
        role: String!
    ): LoginResponse!

    signUpChild(
        parentId: ID!
        name: String!
        username: String!
        password: String!
        nationality: String!
        birthdate: String!
        gender: String!
        role: String!
    ): User!

    refreshTokenUser(
        refreshToken: String!
    ): LoginResponse!

    logout(
        refreshToken: String!
    ): LogoutResponse!
}
`;
