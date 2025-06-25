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
    ): String!

    generateQuestions(story: String!): [Question!]!
  }


  type Query {
    getStoryJobStatus(jobId: ID!): JobStatusResponse!
  }


  type JobResponse {
    jobId: ID!
  }

  type JobStatusResponse {
    status: String!
    story: String
    error: String
  }

`;
