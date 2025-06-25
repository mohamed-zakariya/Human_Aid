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

// GraphQL Mutation
const String generateStoryMutation = r'''
    mutation generateArabicStory(
      $topic: String!,
      $setting: String!,
      $goal: String!,
      $age: String!,
      $length: String!,
      $heroType: String,
    ) {
      generateArabicStory(
        topic: $topic,
        setting: $setting,
        goal: $goal,
        age: $age,
        length: $length,
        heroType: $heroType,
      )
    }
  ''';