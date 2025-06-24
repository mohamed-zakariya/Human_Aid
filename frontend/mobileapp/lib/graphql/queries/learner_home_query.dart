const String getLearnerHomePageQuery = r'''
  query GetLearnerHomePage($userId: ID!) {
    learnerHomePage(userId: $userId) {
      id
      name
      arabic_name
      type
      english_description
      arabic_description
      progress {
        accuracyPercentage
        score
        progressPercentage
      }
      progress_imageUrl
      exercise_imageUrl
    }
  }
''';
