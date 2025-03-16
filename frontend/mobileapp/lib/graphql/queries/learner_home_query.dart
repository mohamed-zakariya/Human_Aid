// queries/learner_home_query.dart

const String getLearnerHomePageQuery = r'''
  query GetLearnerHomePage($userId: ID!) {
    learnerHomePage(userId: $userId) {
      id
      name
      type
      progress {
        accuracyPercentage
        score
      }
    }
  }
''';
