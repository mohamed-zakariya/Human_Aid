export const gamesTypeDefs = `#graphql
type Mutation {
  updategamesProgress(
    userId: ID!
    exerciseId: ID!
    levelId: ID!
    gameId: ID!
    score: Int!
  ): UpdateGameProgressResponse!
}

type UpdateGameProgressResponse {
  success: Boolean!
  message: String!
}
`;