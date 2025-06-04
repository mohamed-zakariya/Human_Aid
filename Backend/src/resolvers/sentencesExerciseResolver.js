// src/resolvers/sentencesExerciseResolver.js
import {updateSentenceProgress } from "../controllers/sentencesExerciseController.js";
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
    updateSentenceProgress: async (_, { userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence}) => {
        return await updateSentenceProgress(userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence);
      },      
  },
};
