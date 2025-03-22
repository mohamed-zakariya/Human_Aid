import { wordsExercise , startExercise , endExercise,updateUserProgress } from "../controllers/wordsExerciseController.js";
import Words from "../models/Words.js"
export const speechResolvers = {
  Query: {
        getWordForExercise: async (_, { level }) => {
          console.log("Fetching words for level:", level);
          const words = await Words.aggregate([
            { $match: { level } },
            { $sample: { size: 10 } }
          ]);
          console.log("Words found:", words);
          return words;
        },
      },
  Mutation: {
    startExercise: async (_, { userId, exerciseId }) => {
      return await startExercise(userId, exerciseId);
    },
    wordsExercise: async (_, { userId, exerciseId, wordId, audioFile }) => {
      return await wordsExercise(userId, exerciseId, wordId, audioFile);
    },
    updateUserProgress: async (_, { userId, exerciseId, wordId, audioFile,spokenWord}) => {
      return await updateUserProgress(userId, exerciseId, wordId, audioFile,spokenWord);
    },
    endExercise: async (_, { userId, exerciseId }) => {
      return await endExercise(userId, exerciseId);
    },
  },
};
