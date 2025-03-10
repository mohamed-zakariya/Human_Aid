import { wordsExercise } from "../controllers/wordsExerciseController.js";

export const speechResolvers = {
  Mutation: {
    wordsExercise: async (_, { userId, exerciseId, wordId, audioFile }) => {
      return await wordsExercise(userId, exerciseId, wordId, audioFile);
    },
  },
};
