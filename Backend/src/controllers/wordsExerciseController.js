
import mongoose from "mongoose";
import { mockTranscribeAudio } from "../services/mockSTT.js";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
export const startExercise = async (userId, exerciseId) => {
  try {
    let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });

    if (!progress) {
      progress = new Exercisesprogress({
        user_id: userId,
        exercise_id: exerciseId,
        start_time: new Date(),
        correct_words: [],
        incorrect_words: [],
        exercise_time_spent: [],
        accuracy_percentage: 0,
        score: 0,
      });

      await progress.save();
      console.log("Exercise progress created:", progress);
    } else {
      progress.start_time = new Date(); // Reset start time when re-entering the exercise
      await progress.save();
      console.log("Exercise progress updated:", progress);
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
    const timeSpent = Math.floor((endTime - progress.start_time) / (1000*60)); // Time in seconds

    const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD format
    const existingEntry = progress.exercise_time_spent.find((entry) => entry.date.toISOString().split("T")[0] === today);

    if (existingEntry) {
      existingEntry.time_spent += timeSpent;
    } else {
      progress.exercise_time_spent.push({ date: new Date(), time_spent: timeSpent });
    }

    progress.start_time = null; // Reset start time

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
      throw new Error("Speech-to-text processing failed or returned an invalid result.");
    }

    const expectedWord = await Words.findById(wordId);
    if (!expectedWord || !expectedWord.word) {
      throw new Error("Word not found or invalid.");
    }

    const isCorrect = spokenWord.toLowerCase().trim() === expectedWord.word.toLowerCase().trim();

    // Convert userId and exerciseId to ObjectId
    const progress = await Exercisesprogress.findOne({
      user_id: new mongoose.Types.ObjectId(userId),
      exercise_id: new mongoose.Types.ObjectId(exerciseId),
    });

    console.log("Progress before wordsExercise:", progress);
    if (!progress) {
      throw new Error("Exercise not started yet.");
    }

    if (isCorrect) {
      if (!progress.correct_words.includes(spokenWord)) {
        progress.correct_words.push(spokenWord);
      }
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

    const totalAttempts = progress.correct_words.length + progress.incorrect_words.length;
    progress.accuracy_percentage =
      totalAttempts > 0 ? (progress.correct_words.length / totalAttempts) * 100 : 0;

    progress.score += isCorrect ? 10 : -5;

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
