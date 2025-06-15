const String getStoryByProgressQuery = r'''
    query getStoryByProgress($learnerId: ID!) {
      getStoryByProgress(learnerId: $learnerId) {
        id
        story
        kind
        morale
        summary
      }
    }
  ''';