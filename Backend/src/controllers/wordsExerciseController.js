import mongoose from "mongoose";
import { mockTranscribeAudio } from "../services/mockSTT.js";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import UserDailyAttempts from "../models/UserDailyAttempts.js";

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

export const wordsExercise = async (userId, exerciseId, wordId, audioFile) => {
  try {
    if (!audioFile || typeof audioFile !== "string") {
      throw new Error("audioFile is required and must be a string");
    }

    const filePath = audioFile.startsWith("http")
      ? audioFile.replace("http://localhost:5500/", "")
      : `uploads/${audioFile}`;

    const spokenWord = await mockTranscribeAudio(filePath);
    if (!spokenWord || typeof spokenWord !== "string") {
      throw new Error("Speech-to-text processing failed.");
    }

    const expectedWord = await Words.findById(wordId);
    if (!expectedWord || !expectedWord.word) {
      throw new Error("Word not found.");
    }

    const isCorrect = spokenWord.toLowerCase().trim() === expectedWord.word.toLowerCase().trim();

    let startOfDay = new Date();
    startOfDay.setUTCHours(0, 0, 0, 0);
    let endOfDay = new Date();
    endOfDay.setUTCHours(23, 59, 59, 999);

    let userAttempt = await UserDailyAttempts.findOne({
      user_id: new mongoose.Types.ObjectId(userId),
      exercise_id: new mongoose.Types.ObjectId(exerciseId),
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    if (!userAttempt) {
      userAttempt = new UserDailyAttempts({
        user_id: new mongoose.Types.ObjectId(userId),
        exercise_id: new mongoose.Types.ObjectId(exerciseId),
        date: new Date(),
        attempts: [],
      });
    }

    const wordAttempt = userAttempt.attempts.find((a) => a.word_id.toString() === wordId);

    if (!wordAttempt) {
      userAttempt.attempts.push({
        word_id: wordId,
        correct_word: expectedWord.word,
        spoken_word: spokenWord,
        is_correct: isCorrect,
        attempts_number: 1,
      });
    } else {
      wordAttempt.attempts_number += 1;
      wordAttempt.spoken_word = spokenWord;
      wordAttempt.is_correct = isCorrect;
    }

    await userAttempt.save();

    let progress = await Exercisesprogress.findOne({
      user_id: new mongoose.Types.ObjectId(userId),
      exercise_id: new mongoose.Types.ObjectId(exerciseId),
    });

    if (!progress) {
      progress = new Exercisesprogress({
        user_id: new mongoose.Types.ObjectId(userId),
        exercise_id: new mongoose.Types.ObjectId(exerciseId),
        correct_words: [],
        incorrect_words: [],
        score: 0,
        accuracy_percentage: 0,
      });
    }

    if (isCorrect) {
      if (!progress.correct_words.includes(spokenWord)) {
        progress.correct_words.push(spokenWord);
        progress.score += 10;
      }
    } else {
      if (wordAttempt.attempts_number >= 3) {
        const incorrectEntry = progress.incorrect_words.find(
          (w) => w.word_id.toString() === wordId
        );

        if (incorrectEntry) {
          incorrectEntry.frequency += 1;
        } else {
          progress.incorrect_words.push({
            word_id: wordId,
            incorrect_word: spokenWord,
            frequency: 1,
          });
        }

        progress.score = Math.max(progress.score - 5, 0);
      }
    }

    const totalAttempts = progress.correct_words.length + progress.incorrect_words.length;
    progress.accuracy_percentage =
      totalAttempts > 0 ? (progress.correct_words.length / totalAttempts) * 100 : 0;

    await progress.save();

    try {
      fs.unlinkSync(filePath);
    } catch (error) {
      console.error("Failed to delete audio file:", error);
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
};
