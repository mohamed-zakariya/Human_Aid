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
        getSentencesByLevel: async (_, { level }) => {
          const validLevels = ['Beginner', 'Intermediate', 'Advanced'];
          if (!validLevels.includes(level)) {
            throw new Error('Invalid level');
          }
          const sentences = await Sentences.aggregate([
            { $match: { level } },
            { $sample: { size: 4 } }
          ]);
          console.log(sentences);
          // Return 4 random sentences for the given level
          return sentences;
        },
  },
      
Mutation: {
    updateSentenceProgress: async (_, { userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence}) => {
        return await updateSentenceProgress(userId, exerciseId,levelId, sentenceId, audioFile,spokenSentence);
      },      
  },
};
