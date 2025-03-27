export const OverallProgressTypeDefs = `#graphql

    type Reward {
        reward_id: ID!
        date_earned: String!
    }

    type WordStats {
        count: Int!
        words: [String]
    }

    type OverallProgress {
        id: ID!
        user_id: ID!
        progress_id: ID!
        completed_exercises: [ID]!
        total_time_spent: Int!
        average_accuracy: Float!
        total_correct_words: WordStats!
        total_incorrect_words: WordStats!
        last_updated: String!
        rewards: [Reward]
    }

    type Query {
        getOverallProgress(userId: ID!): OverallProgress
        getAllOverallProgress: [OverallProgress]
    }

    type Mutation {
        addOverallProgress(
            user_id: ID!
            progress_id: ID!
            completed_exercises: [ID]!
            total_time_spent: Int!
            average_accuracy: Float!
            total_correct_words: WordStatsInput!
            total_incorrect_words: WordStatsInput!
            rewards: [RewardInput]
        ): OverallProgress
    }

    input RewardInput {
        reward_id: ID!
        date_earned: String!
    }

    input WordStatsInput {
        count: Int!
        words: [String]
    }
`;
