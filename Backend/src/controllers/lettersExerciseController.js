import mongoose from "mongoose";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import UserDailyAttempts from "../models/UserDailyAttempts.js";
import { azureTranscribeAudio } from "../config/azureapiConfig.js";
import OverallProgress from "../models/OverallProgress.js";
import Letters from "../models/Letters.js";
import Exercises from "../models/Exercises.js";

export const startExercise = async (userId, exerciseId) => {
    try {
      let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });
  
      if (!progress) {
        progress = new Exercisesprogress({
          user_id: userId,
          exercise_id: exerciseId,
          start_time: new Date(),
          exercise_time_spent: [],
          accuracy_percentage: 0,
          score: 0,
        });
  
        await progress.save();
      } else {
        progress.start_time = new Date(); // Reset start time
        await progress.save();
      }
  
      return { message: "Exercise started", startTime: progress.start_time };
    } catch (error) {
      console.error("Error in startExercise:", error);
      throw new Error("Failed to start exercise.");
    }
  };
  
  export const endExercise = async (userId, exerciseId) => {
    try {
      let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });
  
      if (!progress || !progress.start_time) {
        throw new Error("No active session found for this exercise.");
      }
  
      const endTime = new Date();
      const timeSpent = Math.floor((endTime - progress.start_time) / 60000); // Convert ms to minutes
  
      let startOfDay = new Date();
      startOfDay.setUTCHours(0, 0, 0, 0);
      let endOfDay = new Date();
      endOfDay.setUTCHours(23, 59, 59, 999);
  
      const existingEntry = progress.exercise_time_spent.find((entry) => 
        entry.date >= startOfDay && entry.date <= endOfDay
      );
  
      if (existingEntry) {
        existingEntry.time_spent += timeSpent;
      } else {
        progress.exercise_time_spent.push({ date: new Date(), time_spent: timeSpent });
      }
  
      progress.start_time = null;
      await progress.save();
      return { message: "Exercise ended", timeSpent };
    } catch (error) {
      console.error(error);
      throw new Error("Failed to end exercise.");
    }
  };

  export const updateLetterProgress = async (userId, exerciseId, letterId, audioFile, spokenLetter, timeSpent) => {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      console.log("Received spokenLetter:", spokenLetter);
      if (!spokenLetter || typeof spokenLetter !== "string") {
        throw new Error("Spoken letter (transcribed text) is required");
      }
  
      const filePath = audioFile?.startsWith("http")
        ? audioFile.replace("http://localhost:5500/", "")
        : audioFile ? `uploads/${audioFile}` : null;
  
      const expectedLetter = await Letters.findById(letterId).session(session);
      if (!expectedLetter || !expectedLetter.letter) throw new Error("Letter not found.");
  
      const isCorrect = spokenLetter.toLowerCase().trim() === expectedLetter.letter.toLowerCase().trim();
  
      // Date range for today's attempt
      let startOfDay = new Date(); startOfDay.setUTCHours(0, 0, 0, 0);
      let endOfDay = new Date(); endOfDay.setUTCHours(23, 59, 59, 999);
  
      // Check or create UserDailyAttempts
      let userAttempt = await UserDailyAttempts.findOne({
        user_id: userId,
        exercise_id: exerciseId,
        date: { $gte: startOfDay, $lte: endOfDay },
      }).session(session);
  
      if (!userAttempt) {
        userAttempt = new UserDailyAttempts({
          user_id: userId,
          exercise_id: exerciseId,
          date: new Date(),
          letters_attempts: [],
          words_attempts: [],
          sentences_attempts: [],
        });
      }
  
      let letterAttempt = userAttempt.letters_attempts.find(
        (attempt) => attempt.letter_id.toString() === letterId
      );
  
      if (!letterAttempt) {
        letterAttempt = {
          letter_id: letterId,
          correct_letter: expectedLetter.letter,
          spoken_letter: spokenLetter,
          is_correct: isCorrect,
          attempts_number: 1,
        };
        userAttempt.letters_attempts.push(letterAttempt);
      } else {
        letterAttempt.attempts_number += 1;
        letterAttempt.spoken_letter = spokenLetter;
        letterAttempt.is_correct = isCorrect;
      }
  
      await userAttempt.save({ session });
  
      // Update ExerciseProgress
      let progress = await Exercisesprogress.findOne({
        user_id: userId,
        exercise_id: exerciseId,
      }).session(session);
  
      if (!progress) {
        progress = new Exercisesprogress({
          user_id: userId,
          exercise_id: exerciseId,
          correct_letters: [],
          incorrect_letters: [],
          score: 0,
          accuracy_percentage: 0,
        });
      }
  
      if (isCorrect) {
        const incorrectIndex = progress.incorrect_letters.findIndex(l => l.letter_id.toString() === letterId);
        if (incorrectIndex !== -1) {
          progress.incorrect_letters.splice(incorrectIndex, 1);
        }
  
        if (!progress.correct_letters.includes(spokenLetter)) {
          progress.correct_letters.push(spokenLetter);
          progress.score += 5; // You can decide score for letters separately, like 5 instead of 10
        }
      } else {
        if (letterAttempt.attempts_number >= 3) {
          let incorrectEntry = progress.incorrect_letters.find(l => l.letter_id.toString() === letterId);
          if (incorrectEntry) {
            incorrectEntry.frequency += 1;
          } else {
            progress.incorrect_letters.push({
              letter_id: letterId,
              correct_letter: expectedLetter.letter,
              incorrect_letter: spokenLetter,
              frequency: 1,
            });
          }
          progress.score = Math.max(progress.score - 2, 0); // Deduct 2 points for letters maybe?
        }
      }
  
      const totalAttempts = progress.correct_letters.length + progress.incorrect_letters.length;
      progress.accuracy_percentage = totalAttempts > 0 ? (progress.correct_letters.length / totalAttempts) * 100 : 0;
      await progress.save({ session });
  
      // Handle Overall Progress
      let overall = await OverallProgress.findOne({ user_id: userId }).session(session);
      if (!overall) {
        overall = new OverallProgress({
          user_id: userId,
          progress_id: progress._id,
          completed_exercises: [exerciseId],
          total_time_spent: timeSpent || 0,
          average_accuracy: progress.accuracy_percentage,
          total_correct_letters: { count: isCorrect ? 1 : 0, letters: isCorrect ? [expectedLetter.letter] : [] },
          total_incorrect_letters: { count: !isCorrect ? 1 : 0, letters: !isCorrect ? [expectedLetter.letter] : [] },
        });
      } else {
        if (!overall.completed_exercises.includes(exerciseId)) {
          overall.completed_exercises.push(exerciseId);
        }
  
        const allExerciseProgress = await Exercisesprogress.find({ user_id: userId }).session(session);
  
        let totalTime = 0;
        for (const exercise of allExerciseProgress) {
          for (const timeEntry of exercise.exercise_time_spent) {
            totalTime += timeEntry.time_spent;
          }
        }
  
        overall.total_time_spent = totalTime;
  
        if (isCorrect) {
          const incorrectIdx = overall.total_incorrect_letters.letters.indexOf(spokenLetter);
          if (incorrectIdx !== -1) {
            overall.total_incorrect_letters.letters.splice(incorrectIdx, 1);
            overall.total_incorrect_letters.count = Math.max(overall.total_incorrect_letters.count - 1, 0);
          }
  
          if (!overall.total_correct_letters.letters.includes(expectedLetter.letter)) {
            overall.total_correct_letters.letters.push(expectedLetter.letter);
            overall.total_correct_letters.count += 1;
          }
        } else {
          if (letterAttempt.attempts_number >= 3) {
            if (!overall.total_incorrect_letters.letters.includes(expectedLetter.letter)) {
              overall.total_incorrect_letters.letters.push(expectedLetter.letter);
              overall.total_incorrect_letters.count += 1;
            }
          }
        }
  
        const totalLetters = overall.total_correct_letters.count + overall.total_incorrect_letters.count;
        overall.average_accuracy = totalLetters > 0 ? (overall.total_correct_letters.count / totalLetters) * 100 : 0;
      }
  
      overall.last_updated = new Date();
      await overall.save({ session });
  
      // Commit the transaction
      await session.commitTransaction();
      session.endSession();
  
      if (filePath) {
        try { fs.unlinkSync(filePath); }
        catch (err) { console.error("Failed to delete audio file:", err.message); }
      }
  
      return {
        spokenLetter,
        expectedLetter: expectedLetter.letter,
        isCorrect,
        score: progress.score,
        accuracy: progress.accuracy_percentage,
        overall_accuracy: overall.average_accuracy,
        message: isCorrect ? "Correct!" : "Try again!",
      };
  
    } catch (error) {
      await session.abortTransaction();
      session.endSession();
      console.error(error);
      throw new Error(error.message || "Failed to update letter progress");
    }
  };
  