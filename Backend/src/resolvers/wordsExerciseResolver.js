import { startExercise, endExercise, updateUserProgress } from "../controllers/wordsExerciseController.js";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import Exercises from "../models/Exercises.js";
import mongoose from "mongoose";

export const speechResolvers = {
  Query: {
    getWordForExercise: async (_, { userId, exerciseId, level }) => {
      const MAX_WORDS = 15;

      // Step 1: Fetch the exercise and resolve levelId from name
      const exercise = await Exercises.findById(exerciseId);
      if (!exercise) throw new Error('Exercise not found');

      const levelNameMap = {
        Beginner: "Level 1",
        Intermediate: "Level 2",
        Advanced: "Level 3"
      };

      const dbLevelName = levelNameMap[level];
      if (!dbLevelName) {
        throw new Error(`Invalid level input: ${level}`);
      }

      const matchingLevel = exercise.levels.find(lvl => lvl.name === dbLevelName);
      if (!matchingLevel) {
        throw new Error(`Level '${dbLevelName}' not found in exercise`);
      }

      // Use the ObjectId _id of the level, not level_id string field
      const levelId = matchingLevel._id;

      // Step 2: Get user's progress for this exercise
const progress = await Exercisesprogress.findOne({
  user_id: new mongoose.Types.ObjectId(userId),
  exercise_id: new mongoose.Types.ObjectId(exerciseId)
});


      if (!progress) {
        // No progress yet — return 15 random words
        return await Words.aggregate([
          { $match: { level } },
          { $sample: { size: MAX_WORDS } }
        ]);
      }

      // Step 3: Get progress for this level using ObjectId equals
      const levelProgress = progress.levels.find(lvl =>
        lvl.level_id && lvl.level_id.equals(levelId)
      );

      const incorrectWords = levelProgress?.incorrect_items || [];
      const correctWords = levelProgress?.correct_items || [];

      // Step 4: Fetch incorrect word docs (prioritized)
      const incorrectWordDocs = await Words.find({
        word: { $in: incorrectWords },
        level
      });

      const neededCount = MAX_WORDS - incorrectWordDocs.length;

      // Step 5: Fetch new random words excluding already answered
      const newWords = await Words.aggregate([
        {
          $match: {
            word: { $nin: [...incorrectWords, ...correctWords] },
            level
          }
        },
        { $sample: { size: neededCount } }
      ]);

      const result = [...incorrectWordDocs, ...newWords].slice(0, MAX_WORDS);

      console.log(`Returning ${result.length} words for user ${userId} at level ${level}`);

      return result;
    }
  },

  Mutation: {
    startExercise: async (_, { userId, exerciseId }) => {
      return await startExercise(userId, exerciseId);
    },
    updateUserProgress: async (_, { userId, exerciseId, wordId, levelId, audioFile, spokenWord }) => {
      return await updateUserProgress(userId, exerciseId, wordId, levelId, audioFile, spokenWord);
    },
    endExercise: async (_, { userId, exerciseId }) => {
      return await endExercise(userId, exerciseId);
    },
  },
};
