export const storyGeneratorTypeDefs = `#graphql
  type Query {
    _: Boolean
  }

  type Question {
    question: String!
    choices: [String!]!
    correctIndex: Int!
  }

  type Mutation {
    generateArabicStory(
      topic: String!,
      setting: String!,
      goal: String!,
      age: String!,
      length: String!,
      heroType: String
    ): JobResponse!

    generateQuestions(story: String!): JobResponse!
  }


type Query {
  getStoryJobStatus(jobId: ID!): JobStatusResponse!
  getQuestionsJobStatus(jobId: ID!): QuestionsJobStatusResponse!
}


  type JobResponse {
    jobId: ID!
  }

  type JobStatusResponse {
    status: String!
    story: String
    error: String
  }


  type QuestionsJobStatusResponse {
    status: String!
    questions: [Question]
    error: String
  }

`;
