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

type Story {
  id: ID!
  story: String!
  kind: String!
  summary: String
  morale: String!
}

type UserStats {
  numAdults: Int!
  numChildren: Int!
  numParents: Int!
}

type Query {
  getWords: [Word!]!
  getWord(id: ID!): Word
  getSentences: [Sentence!]!
  getSentence(id: ID!): Sentence
  getUserStats: UserStats!   
  getAllParentsWithChildren: [Parent!]!
  getAllUsers: [User!]!  
  getStories: [Story!]!
  getStory(id: ID!): Story
  getStoryByProgress(learnerId: ID!): [Story]
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
  createStory(story: String!, kind: String!, summary: String, morale: String!): Story!
  updateStory(id: ID!, story: String, kind: String, summary: String, morale: String): Story!
  deleteStory(id: ID!): Story!
}

type AuthPayload {
  accessToken: String!
  refreshToken: String!
  user: User!
}
`;