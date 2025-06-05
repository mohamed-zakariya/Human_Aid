const String updateSocreMutation = """
    mutation UpdateGamesProgress(
      \$userId: ID!,
      \$exerciseId: ID!,
      \$levelId: ID!,
      \$gameId: ID!,
      \$score: Int!
    ) {
      updategamesProgress(
        userId: \$userId,
        exerciseId: \$exerciseId,
        levelId: \$levelId,
        gameId: \$gameId,
        score: \$score
      ) {
        success
        message
      }
    }
""";

