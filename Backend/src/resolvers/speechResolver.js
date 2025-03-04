import { mockTranscribeAudio } from "../services/mockSTT.js";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";

export const speechResolvers = {
  Mutation: {
    processSpeech: async (_, { userId, exerciseId, wordId, audioFile }) => {
      try {
        // Validate audioFile
        if (!audioFile || typeof audioFile !== 'string') {
          throw new Error('audioFile is required and must be a string');
        }

        // Construct file path
        const filePath = audioFile.startsWith("http")
          ? audioFile.replace("http://localhost:5500/", "")
          : `uploads/${audioFile}`;

        // Step 1: Simulated STT processing
        const spokenWord = await mockTranscribeAudio(filePath);
        console.log('Transcribed word:', spokenWord); // Debugging
        if (!spokenWord || typeof spokenWord !== 'string') {
          throw new Error('Speech-to-text processing failed or returned an invalid result.');
        }

        // Step 2: Get expected word from DB
        const expectedWord = await Words.findById(wordId);
        if (!expectedWord || !expectedWord.word) {
          throw new Error('Word not found or invalid.');
        }

        // Step 3: Compare words
        const isCorrect = spokenWord.toLowerCase().trim() === expectedWord.word.toLowerCase().trim();

        // Step 4: Fetch existing progress record
        let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });

        if (!progress) {
          // Create new progress entry if not exists
          progress = new Exercisesprogress({
            user_id: userId,
            exercise_id: exerciseId,
            correct_words: [],
            incorrect_words: [],
            exercise_time_spent: [],
            accuracy_percentage: 0,
            score: 0,
          });
        }

        // Step 5: Update progress
        if (isCorrect) {
          progress.correct_words.push(spokenWord);
        } else {
          const incorrectWordIndex = progress.incorrect_words.findIndex(
            (w) => w.word_id.toString() === wordId
          );
          if (incorrectWordIndex !== -1) {
            progress.incorrect_words[incorrectWordIndex].frequency += 1;
          } else {
            progress.incorrect_words.push({
              word_id: wordId,
              incorrect_word: spokenWord,
              frequency: 1,
            });
          }
        }

        // Step 6: Recalculate accuracy
        const totalAttempts = progress.correct_words.length + progress.incorrect_words.length;
        progress.accuracy_percentage =
          totalAttempts > 0 ? (progress.correct_words.length / totalAttempts) * 100 : 0;

        // Step 7: Adjust Score (simple logic: +10 for correct, -5 for incorrect)
        progress.score += isCorrect ? 10 : -5;

        // Save progress
        await progress.save();

        // Clean up: Remove audio file after processing
        try {
          fs.unlinkSync(filePath);
        } catch (error) {
          console.error('Failed to delete audio file:', error);
        }

        return {
          spokenWord,
          expectedWord: expectedWord.word,
          isCorrect,
          message: isCorrect ? "Correct!" : "Try again!",
        };
      } catch (error) {
        console.error(error);
        throw new Error("Speech processing failed.");
      }
    },
  },
};