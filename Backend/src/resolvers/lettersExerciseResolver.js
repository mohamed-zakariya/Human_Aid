import { updateLetterProgress } from "../controllers/lettersExerciseController.js";
import Letters from "../models/Letters.js";

export const lettersExerciseResolver = {
  Query: {
    getLettersForExercise: async () => {
        try {
            console.log("Fetching all letters from database");
            const letters = await Letters.find({});
            console.log(`Found ${letters.length} letters`);
            return letters;
          } catch (error) {
            console.error("Error fetching letters:", error);
            throw new Error("Could not fetch letters");
          }
        },
      },
  Mutation: {
    updateLetterProgress: async (_, { userId, exerciseId,levelId, letterId, audioFile,spokenLetter}) => {
          return await updateLetterProgress(userId, exerciseId,levelId, letterId, audioFile,spokenLetter);
        },
  },
};
