import mongoose from "mongoose";
import { mockTranscribeAudio } from "../services/mockSTT.js";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
import { azureTranscribeAudio } from "../config/azureapiConfig.js";
import OverallProgress from "../models/OverallProgress.js";
export const startExercise = async (userId, exerciseId) => {
  try {
    let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });

    if (!progress) {
      progress = new Exercisesprogress({
        user_id: userId,
        exercise_id: exerciseId,
        total_time_spent: 0,
        session_start: new Date(),
        levels: [],
      });

      await progress.save();
    } else {
      progress.session_start = new Date(); // Reset session start time
      await progress.save();
    }

    // Ensure OverallProgress exists for the user
    let overall = await OverallProgress.findOne({ user_id: userId });
    if (!overall) {
      overall = new OverallProgress({
        user_id: userId,
        progress_by_exercise: [],
        overall_stats: {
          total_time_spent: 0,
          combined_accuracy: 0,
          average_score_all: 0,
        },
      });
      await overall.save();
    }

    return { message: "Exercise started", startTime: progress.session_start };
  } catch (error) {
    console.error("Error in startExercise:", error);
    throw new Error("Failed to start exercise.");
  }
};

export const endExercise = async (userId, exerciseId) => {
  try {
    let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });

    if (!progress || !progress.session_start) {
      throw new Error("No active session found for this exercise.");
    }

    const endTime = new Date();
    const timeSpent = Math.floor((endTime - progress.session_start) / 1000); // Convert ms to seconds

    // Update total time spent in Exercisesprogress
    progress.total_time_spent += timeSpent;
    progress.session_start = null; // Clear session start time
    await progress.save();

    // Update OverallProgress
    let overall = await OverallProgress.findOne({ user_id: userId });
    if (!overall) {
      throw new Error("Overall progress not found for the user.");
    }

    // Find or create the exercise-specific progress entry
    let exerciseProgress = overall.progress_by_exercise.find(
      (p) => p.exercise_id.toString() === exerciseId.toString()
    );

    if (!exerciseProgress) {
      exerciseProgress = {
        exercise_id: exerciseId,
        stats: {
          total_correct: { count: 0, items: [] },
          total_incorrect: { count: 0, items: [] },
          total_items_attempted: 0,
          accuracy_percentage: 0,
          average_game_score: 0,
          time_spent_seconds: 0,
        },
      };
      overall.progress_by_exercise.push(exerciseProgress);
    }

    // Update time spent for this exercise
    exerciseProgress.stats.time_spent_seconds += timeSpent;

    // Recalculate overall stats
    let totalCorrect = 0;
    let totalAttempted = 0;
    let totalTime = 0;

    for (const ex of overall.progress_by_exercise) {
      totalCorrect += ex.stats.total_correct.count;
      totalAttempted += ex.stats.total_items_attempted;
      totalTime += ex.stats.time_spent_seconds;
    }

    overall.overall_stats.total_time_spent = totalTime;
    overall.overall_stats.combined_accuracy = totalAttempted > 0
      ? (totalCorrect / totalAttempted) * 100
      : 0;

    await overall.save();

    return { message: "Exercise ended", timeSpent };
  } catch (error) {
    console.error("Error in endExercise:", error);
    throw new Error("Failed to end exercise.");
  }
};

export const updateUserProgress = async (userId, exerciseId, wordId, levelId, audioFile, spokenWord, timeSpent) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    validateSpokenWord(spokenWord);

    const filePath = resolveFilePath(audioFile);
    console.log("Resolved file path:", filePath);
    const expectedWord = await getExpectedWord(wordId, session);
    const isCorrect = compareWords(spokenWord, expectedWord.word);

    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      wordId,
      spokenWord,
      expectedWord.word,
      isCorrect,
      session
    );

    const progress = await updateExerciseProgress(
      userId,
      exerciseId,
      wordId,
      levelId,
      spokenWord,
      expectedWord.word,
      isCorrect,
      userAttempt,
      session
    );

    const overall = await updateOverallProgress(
      userId,
      exerciseId,
      wordId,
      spokenWord,
      expectedWord.word,
      isCorrect,
      timeSpent,
      session
    );

    await session.commitTransaction();
    return {
      spokenWord,
      expectedWord: expectedWord.word,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
    }
    console.error(error);
    throw new Error(error.message || "Failed to update progress");
  } finally {
    session.endSession();
    // Only clean up the audio file if it was resolved earlier
    try {
      if (audioFile) {
        const filePath = resolveFilePath(audioFile);
        cleanupAudio(filePath);
      }
    } catch (cleanupError) {
      console.warn("Audio cleanup failed:", cleanupError.message);
    }
  }
};

function validateSpokenWord(spokenWord) {
  console.log("Spoken Word received:", spokenWord);  // Add this line for debugging
  if (!spokenWord || typeof spokenWord !== "string") {
    throw new Error("Spoken word (transcribed text) is required");
  }
}


function resolveFilePath(audioFile) {
  return audioFile?.startsWith("http")
    ? audioFile.replace("http://localhost:5500/", "")
    : audioFile ? `uploads/${audioFile}` : null;
}

async function getExpectedWord(wordId, session) {
  const word = await Words.findById(wordId).session(session);
  if (!word || !word.word) throw new Error("Word not found.");
  return word;
}

function compareWords(spoken, expected) {
  return spoken.toLowerCase().trim() === expected.toLowerCase().trim();
}
async function updateUserDailyAttempts(userId, levelId, wordId, spokenWord, correctWord, isCorrect, session)
{

  const startOfDay = new Date(); startOfDay.setUTCHours(0, 0, 0, 0);
  const endOfDay = new Date(); endOfDay.setUTCHours(23, 59, 59, 999);

  let userAttempt = await DailyAttemptTracking.findOne({
    user_id: userId,
    date: { $gte: startOfDay, $lte: endOfDay },
  }).session(session);

  if (!userAttempt) {
    userAttempt = new DailyAttemptTracking({
      user_id: userId,
      date: new Date(),
      words_attempts: [],
      letters_attempts: [],
      sentences_attempts: [],
      game_attempts: []
    });
  }

  let wordAttempt = userAttempt.words_attempts.find(attempt =>
    attempt.word_id.toString() === wordId && attempt.level_id.toString() === levelId
  );

  if (!wordAttempt) {
    wordAttempt = {
      word_id: wordId,
      correct_word: correctWord,
      spoken_word: spokenWord,
      is_correct: isCorrect,
      attempts_number: 1,
      level_id: levelId,
      timestamp: new Date()
    };
    userAttempt.words_attempts.push(wordAttempt);
  } else {
    wordAttempt.attempts_number += 1;
    wordAttempt.spoken_word = spokenWord;
    wordAttempt.is_correct = isCorrect;
    wordAttempt.timestamp = new Date();
  }

  await userAttempt.save({ session });
  return userAttempt;
}

async function updateExerciseProgress(userId, exerciseId, wordId, levelId, spokenWord, correctWord, isCorrect, userAttempt, session)
 {
  let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId }).session(session);

  if (!progress) {
    progress = new Exercisesprogress({
      user_id: userId,
      exercise_id: exerciseId,
      total_time_spent: 0,
      session_start: new Date(),
      levels: []
    });
  }

  // Find or create the level in progress
  let levelProgress = progress.levels.find(l => l.level_id.toString() === levelId.toString());

if (!levelProgress) {
  levelProgress = {
    level_id: levelId,
    correct_items: [],
    incorrect_items: [],
    games: []
  };
  progress.levels.push(levelProgress);
}


  if (isCorrect) {
    // Remove from incorrect items if present
    const incorrectIndex = levelProgress.incorrect_items.findIndex(w => w === correctWord);
    if (incorrectIndex !== -1) levelProgress.incorrect_items.splice(incorrectIndex, 1);

    // Add the correct word if not already included
    const correctWordExists = levelProgress.correct_items.some(item => item === correctWord);
    if (!correctWordExists) {
      levelProgress.correct_items.push(correctWord);
    }
  } else {
    // Add the correct word to incorrect_items if not already present
    const incorrectWordExists = levelProgress.incorrect_items.includes(correctWord);
    if (!incorrectWordExists) {
      levelProgress.incorrect_items.push(correctWord);
    }
  }

  // Recalculate accuracy percentage
  const totalItems = levelProgress.correct_items.length + levelProgress.incorrect_items.length;
  const accuracyPercentage = totalItems > 0 ? (levelProgress.correct_items.length / totalItems) * 100 : 0;

  // Optionally, you can track time spent (adjust based on your app logic)
  const timeSpent = 0; // Adjust as needed
  progress.total_time_spent += timeSpent;

  // Save the progress data
  await progress.save({ session });

  return {
    levelProgress,
    accuracyPercentage
  };
}

async function updateOverallProgress(userId, exerciseId, wordId, spokenWord, correctWord, isCorrect, timeSpent, session) {
  let overall = await OverallProgress.findOne({ user_id: userId }).session(session);

  if (!overall) {
    overall = new OverallProgress({
      user_id: userId,
      progress_by_exercise: [],
      overall_stats: {
        total_time_spent: timeSpent || 0,
        combined_accuracy: isCorrect ? 100 : 0,
        average_score_all: 0
      }
    });
  }

  // Find or create the exercise-specific progress entry
  let exerciseProgress = overall.progress_by_exercise.find(
    p => p.exercise_id.toString() === exerciseId.toString()
  );

  if (!exerciseProgress) {
    exerciseProgress = {
      exercise_id: exerciseId,
      stats: {
        total_correct: { count: 0, items: [] },
        total_incorrect: { count: 0, items: [] },
        total_items_attempted: 0,
        accuracy_percentage: 0,
        average_game_score: 0,
        time_spent_seconds: 0
      }
    };
    overall.progress_by_exercise.push(exerciseProgress);
  }

  const stats = exerciseProgress.stats;

  // Remove the word from both correct and incorrect lists (clean up)
  stats.total_correct.items = stats.total_correct.items.filter(w => w !== correctWord);
  stats.total_incorrect.items = stats.total_incorrect.items.filter(w => w !== correctWord);

  // Check if the word was not previously attempted
  const alreadyAttempted =
    stats.total_correct.items.includes(correctWord) ||
    stats.total_incorrect.items.includes(correctWord);

  // Add to correct or incorrect list based on result
  if (isCorrect) {
    stats.total_correct.items.push(correctWord);
  } else {
    stats.total_incorrect.items.push(correctWord);
  }

  // If it was not already attempted, count it as a new unique attempt
  if (!alreadyAttempted) {
    stats.total_items_attempted += 1;
  }

  // Update counts
  stats.total_correct.count = stats.total_correct.items.length;
  stats.total_incorrect.count = stats.total_incorrect.items.length;

  // Recalculate accuracy
  stats.accuracy_percentage = stats.total_items_attempted > 0
    ? (stats.total_correct.count / stats.total_items_attempted) * 100
    : 0;

  // Time spent
  stats.time_spent_seconds += timeSpent || 0;

  // Update overall stats across all exercises
  let totalCorrect = 0;
  let totalAttempted = 0;
  let totalTime = 0;

  for (const ex of overall.progress_by_exercise) {
    totalCorrect += ex.stats.total_correct.count;
    totalAttempted += ex.stats.total_items_attempted;
    totalTime += ex.stats.time_spent_seconds;
  }

  overall.overall_stats.total_time_spent = totalTime;
  overall.overall_stats.combined_accuracy = totalAttempted > 0
    ? (totalCorrect / totalAttempted) * 100
    : 0;

  await overall.save({ session });
  return overall;
}
