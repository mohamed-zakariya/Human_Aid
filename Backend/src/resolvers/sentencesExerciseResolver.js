// src/resolvers/sentencesExerciseResolver.js
import {startExercise , endExercise,updateSentenceProgress } from "../controllers/sentencesExerciseController.js";
import Sentences from "../models/Sentences.js"
export const sentencesExerciseResolver = {
  Query: {
        getSentenceForExercise: async (_, { level }) => {
          console.log("Fetching words for level:", level);
          const sentences = await Sentences.aggregate([
            { $match: { level } },
            { $sample: { size: 5 } }
          ]);
          console.log("Sentences found:", sentences);
          return sentences;
        },
      },
Mutation: {
    startExercise: async (_, { userId, exerciseId }) => {
      return await startExercise(userId, exerciseId);
    },
    updateSentenceProgress: async (_, { userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence}) => {
        return await updateSentenceProgress(userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence);
      },      
    endExercise: async (_, { userId, exerciseId }) => {
      return await endExercise(userId, exerciseId);
    },
  },
};
