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

type Query {
  getWords: [Word!]!
  getWord(id: ID!): Word
  getSentences: [Sentence!]!
  getSentence(id: ID!): Sentence
}

type Mutation {
  createWord(word: String!, level: String!, image: Upload): Word!
  updateWord(id: ID!, word: String, level: String, image: Upload): Word!
  deleteWord(id: ID!): Word!
  loginAdmin(username: String!, password: String!): AuthPayload!
  createSentence(sentence: String!, level: String!): Sentence!
  updateSentence(id: ID!, sentence: String, level: String): Sentence!
  deleteSentence(id: ID!): Sentence!
}

type AuthPayload {
  accessToken: String!
  refreshToken: String!
  user: User!
}

`;
