import mongoose from "mongoose";
import { mockTranscribeAudio } from "../services/mockSTT.js";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import UserDailyAttempts from "../models/UserDailyAttempts.js";
import { azureTranscribeAudio } from "../config/azureapiConfig.js";
import OverallProgress from "../models/OverallProgress.js";
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

    const spokenWord = await azureTranscribeAudio(filePath);
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
            correct_word: expectedWord,
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
export const updateUserProgress = async (userId, exerciseId, wordId, audioFile, spokenWord, timeSpent) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    console.log("Received spokenWord:", spokenWord);
    if (!spokenWord || typeof spokenWord !== "string") {
      throw new Error("Spoken word (transcribed text) is required");
    }

    const filePath = audioFile?.startsWith("http")
      ? audioFile.replace("http://localhost:5500/", "")
      : audioFile ? `uploads/${audioFile}` : null;

    const expectedWord = await Words.findById(wordId).session(session);
    if (!expectedWord || !expectedWord.word) throw new Error("Word not found.");

    const isCorrect = spokenWord.toLowerCase().trim() === expectedWord.word.toLowerCase().trim();

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
        attempts: [],
      });
    }

    let wordAttempt = userAttempt.attempts.find(
      (attempt) => attempt.word_id.toString() === wordId
    );
    
    if (!wordAttempt) {
      // Initialize if not found
      wordAttempt = {
        word_id: wordId,
        correct_word: expectedWord.word,
        spoken_word: spokenWord,
        is_correct: isCorrect,
        attempts_number: 1,
      };
      userAttempt.attempts.push(wordAttempt);
    } else {
      // Safe increment if found
      wordAttempt.attempts_number += 1;
      wordAttempt.spoken_word = spokenWord;
      wordAttempt.is_correct = isCorrect;
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
        correct_words: [],
        incorrect_words: [],
        score: 0,
        accuracy_percentage: 0,
      });
    }

    if (isCorrect) {
      // ✅ Remove the word from incorrect_words if it exists
      const incorrectIndex = progress.incorrect_words.findIndex(w => w.word_id.toString() === wordId);
      if (incorrectIndex !== -1) {
        progress.incorrect_words.splice(incorrectIndex, 1);
      }
    
      // ✅ Add to correct_words if not already there
      if (!progress.correct_words.includes(spokenWord)) {
        progress.correct_words.push(spokenWord);
        progress.score += 10;
      }
    } else {
      if (wordAttempt.attempts_number >= 3) {
        let incorrectEntry = progress.incorrect_words.find(w => w.word_id.toString() === wordId);
        if (incorrectEntry) {
          incorrectEntry.frequency += 1;
        } else {
          progress.incorrect_words.push({
            word_id: wordId,
            correct_word: expectedWord.word,
            incorrect_word: spokenWord,
            frequency: 1,
          });
        }
        progress.score = Math.max(progress.score - 5, 0);
      }
    }

    const totalAttempts = progress.correct_words.length + progress.incorrect_words.length;
    progress.accuracy_percentage = totalAttempts > 0 ? (progress.correct_words.length / totalAttempts) * 100 : 0;
    await progress.save({ session });

    // 🔥 Now handle OverallProgress Update 🔥
    let overall = await OverallProgress.findOne({ user_id: userId }).session(session);
    if (!overall) {
      overall = new OverallProgress({
        user_id: userId,
        progress_id: progress._id,
        completed_exercises: [exerciseId],
        total_time_spent: timeSpent || 0,
        average_accuracy: progress.accuracy_percentage,
        total_correct_words: { count: isCorrect ? 0 : 0, words: isCorrect ? [] : [] },
        total_incorrect_words: { count: !isCorrect ? 0 : 0, words: !isCorrect ? [] : [] },
      });
    } else {
      // ✅ Add exerciseId to completed_exercises if not already there
      if (!overall.completed_exercises.includes(exerciseId)) {
        overall.completed_exercises.push(exerciseId);
      }
    
      // 🔄 Recalculate total time spent from all exercise progress
      const allExerciseProgress = await Exercisesprogress.find({ user_id: userId }).session(session);

      let totalTime = 0;
      for (const exercise of allExerciseProgress) {
        for (const timeEntry of exercise.exercise_time_spent) {
          totalTime += timeEntry.time_spent;
        }
      }

      overall.total_time_spent = totalTime;

    
      if (isCorrect) {
        // ✅ Remove from incorrect if present
        const incorrectIdx = overall.total_incorrect_words.words.indexOf(spokenWord);
        if (incorrectIdx !== -1) {
          overall.total_incorrect_words.words.splice(incorrectIdx, 1);
          overall.total_incorrect_words.count = Math.max(overall.total_incorrect_words.count - 1, 0);
        }
      
        // ✅ Add to correct if not already there
        if (!overall.total_correct_words.words.includes(expectedWord.word)) {
          overall.total_correct_words.words.push(expectedWord.word);
          overall.total_correct_words.count += 1;
        }
      } else {
        if (!overall.total_incorrect_words.words.includes(expectedWord.word)) {
          overall.total_incorrect_words.words.push(expectedWord.word);
          overall.total_incorrect_words.count += 1;
        }
      }
    
      const totalWords = overall.total_correct_words.count + overall.total_incorrect_words.count;
      overall.average_accuracy = totalWords > 0 ? (overall.total_correct_words.count / totalWords) * 100 : 0;
    }
    overall.last_updated = new Date();
    await overall.save({ session });
    // ✅ Commit the transaction
    await session.commitTransaction();
    session.endSession();

    // Clean up audio
    if (filePath) {
      try { fs.unlinkSync(filePath); } 
      catch (err) { console.error("Failed to delete audio file:", err.message); }
    }

    return {
      spokenWord,
      expectedWord: expectedWord.word,
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
    throw new Error(error.message || "Failed to update progress");
  }
};

