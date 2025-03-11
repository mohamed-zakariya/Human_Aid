import { wordsExercise , startExercise , endExercise } from "../controllers/wordsExerciseController.js";

export const speechResolvers = {
  Mutation: {
    startExercise: async (_, { userId, exerciseId }) => {
      return await startExercise(userId, exerciseId);
    },
    wordsExercise: async (_, { userId, exerciseId, wordId, audioFile }) => {
      return await wordsExercise(userId, exerciseId, wordId, audioFile);
    },
    endExercise: async (_, { userId, exerciseId }) => {
      return await endExercise(userId, exerciseId);
    },
  },
};
