export const wordsTypeDefs = `#graphql
  type Word {
    _id: ID!
    word: String!
    level: String!
}

type Query {
  getWordForExercise(level: String!): [Word]
}
`;