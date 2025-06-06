export const adminTypeDefs = `#graphql
scalar Upload
type Word {
  id: ID!
  word: String!
  level: String!
  imageUrl: String
}

type Sentence {
  id: ID!
  sentence: String!
  level: String!
}

type UserStats {
  numAdults: Int!
  numChildren: Int!
  numParents: Int!
}

type Parent {
  id: ID!
  name: String!
  email: String!
  phoneNumber: String
  nationality: String
  birthdate: String
  gender: String
  linkedChildren: [User!]!
}

type User {
  id: ID!
  name: String!
  username: String!
  email: String
  role: String!
  # Add other fields as needed
}

type Query {
  getWords: [Word!]!
  getWord(id: ID!): Word
  getSentences: [Sentence!]!
  getSentence(id: ID!): Sentence
  getUserStats: UserStats!   
  getAllParentsWithChildren: [Parent!]!
  getAllUsers: [User!]!  
}

type Mutation {
  createWord(word: String!, level: String!, image: Upload): Word!
  updateWord(id: ID!, word: String, level: String, image: Upload): Word!
  deleteWord(id: ID!): Word!
  loginAdmin(username: String!, password: String!): AuthPayload!
  createSentence(sentence: String!, level: String!): Sentence!
  updateSentence(id: ID!, sentence: String, level: String): Sentence!
  deleteSentence(id: ID!): Sentence!
  deleteParentAndChildren(parentId: ID!): Boolean!
  deleteUser(userId: ID!): Boolean!
}

type AuthPayload {
  accessToken: String!
  refreshToken: String!
  user: User!
}

`;