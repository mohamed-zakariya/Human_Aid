import {startExercise , endExercise,updateUserProgress } from "../controllers/wordsExerciseController.js";
import Words from "../models/Words.js"
import Exercisesprogress from "../models/Exercisesprogress.js";
import mongoose from "mongoose";
export const speechResolvers = {
  Query: {
    getWordForExercise: async (_, { userId, exerciseId, level }) => {
      console.log("Fetching words for level:", level);
    
      const exerciseProgress = await Exercisesprogress.findOne({
        user_id: new mongoose.Types.ObjectId(userId),
        exercise_id: new mongoose.Types.ObjectId(exerciseId),
      });
    
      const correctTexts = exerciseProgress?.correct_words || [];
      const incorrectWordIds = (exerciseProgress?.incorrect_words || []).map(
        (entry) => entry.word_id
      );
    
      // Step 1: Get incorrect words (prioritized)
      const incorrectWords = await Words.find({
        _id: { $in: incorrectWordIds },
        level,
      });
    
      // Step 2: Get remaining random words to reach 15
      const remainingCount = 15 - incorrectWords.length;
    
      const randomWords = await Words.aggregate([
        {
          $match: {
            _id: { $nin: incorrectWordIds },
            word: { $nin: correctTexts },
            level,
          },
        },
        { $sample: { size: remainingCount > 0 ? remainingCount : 0 } },
      ]);
    
      const finalWords = [...incorrectWords, ...randomWords];
      console.log("Words returned:", finalWords.length);
      return finalWords;
    }
  },    
  Mutation: {
    startExercise: async (_, { userId, exerciseId }) => {
      return await startExercise(userId, exerciseId);
    },
    // wordsExercise: async (_, { userId, exerciseId, wordId, audioFile }) => {
    //   return await wordsExercise(userId, exerciseId, wordId, audioFile);
    // },
    updateUserProgress: async (_, { userId, exerciseId, wordId,levelId,audioFile,spokenWord}) => {
      return await updateUserProgress(userId, exerciseId, wordId,levelId, audioFile,spokenWord);
    },
    endExercise: async (_, { userId, exerciseId }) => {
      return await endExercise(userId, exerciseId);
    },
  },
};
