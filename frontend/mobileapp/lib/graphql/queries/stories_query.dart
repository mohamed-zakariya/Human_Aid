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


const String generateStoryMutation = '''
    mutation generateArabicStory(
      \$topic: String!,
      \$setting: String!,
      \$goal: String!,
      \$age: String!,
      \$length: String!,
      \$heroType: String
    ) {
      generateArabicStory(
        topic: \$topic,
        setting: \$setting,
        goal: \$goal,
        age: \$age,
        length: \$length,
        heroType: \$heroType
      ) {
        jobId
      }
    }
''';

const String getStoryJobStatusQuery = '''
    query getStoryJobStatus(\$jobId: ID!) {
      getStoryJobStatus(jobId: \$jobId) {
        story
        status
        error
      }
    }
''';

const String generateQuestionsMutation = '''

  mutation generateQuestions(\$story: String!){
    generateQuestions(story: \$story) {
      jobId
    }
  }

''';
const String getQuestionsJobStatusQuery = '''

  query getQuestionsJobStatus(\$jobId: ID!){
    getQuestionsJobStatus(jobId: \$jobId) {
      questions {
        choices
        question
        correctIndex
      }
      status
      error
    }
  }

''';
