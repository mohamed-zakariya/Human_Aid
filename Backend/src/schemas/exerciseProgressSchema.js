export const ExercisesprogressTypeDefs = `#graphql

    type ExerciseTimeSpent {
        date: String!
        time_spent: Int!
    }

    type IncorrectWord {
        word_id: ID!
        incorrect_word: String!
        frequency: Int!
    }

    type StoryQuestion {
        question_id: ID
        is_correct: Boolean!
    }

    type SummaryEvaluation {
        submitted_summary: String!
        score: Int!
    }

    type Story {
        story_id: ID
        story_questions: [StoryQuestion]
        summary_evaluation: SummaryEvaluation
    }

    type Exercisesprogress {
        id: ID!
        exercise_id: ID!
        user_id: ID!
        exercise_time_spent: [ExerciseTimeSpent]!
        start_time: String
        correct_words: [String]
        incorrect_words: [IncorrectWord]
        story: Story
        accuracy_percentage: Float!
        score: Int!
    }
    

    type Query {
        getExercisesprogress(userId: ID!): Exercisesprogress
        getAllExercisesprogress: [Exercisesprogress]
        getLearntWordsbyId(userId: ID!):  [String]
    }
    
    type Mutation {
        addExercisesprogress(
            exercise_id: ID!
            user_id: ID!
            exercise_time_spent: [ExerciseTimeSpentInput]!
            start_time: String
            correct_words: [String]
            incorrect_words: [IncorrectWordInput]
            story: StoryInput
            accuracy_percentage: Float!
            score: Int!
        ): Exercisesprogress
    }

    input ExerciseTimeSpentInput {
        date: String!
        time_spent: Int!
    }

    input IncorrectWordInput {
        word_id: ID!
        incorrect_word: String!
        frequency: Int!
    }

    input StoryQuestionInput {
        question_id: ID
        is_correct: Boolean!
    }

    input SummaryEvaluationInput {
        submitted_summary: String!
        score: Int!
    }

    input StoryInput {
        story_id: ID
        story_questions: [StoryQuestionInput]
        summary_evaluation: SummaryEvaluationInput
    }
`;
