import mongoose from "mongoose";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
import { azureTranscribeAudio } from "../config/azureapiConfig.js";
import OverallProgress from "../models/OverallProgress.js";
import Letters from "../models/Letters.js";
import Exercises from "../models/Exercises.js";

export const updateLetterProgress = async (userId, exerciseId, levelId, letterId, audioFile, spokenLetter, timeSpent) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  let filePath; // Declare filePath outside the try block
  try {
    validateSpokenLetter(spokenLetter);

    filePath = resolveFilePath(audioFile); // Assign filePath here
    const expectedLetter = await getExpectedLetter(letterId, session);
    const isCorrect = compareLetters(spokenLetter, expectedLetter.letter);

    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      letterId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      session
    );

    const progress = await updateExerciseProgress(
      userId,
      exerciseId,
      levelId,
      letterId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      userAttempt,
      session
    );

    const overall = await updateOverallProgress(
      userId,
      exerciseId,
      letterId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      timeSpent,
      session
    );

    await session.commitTransaction();
    return {
      spokenLetter,
      expectedLetter: expectedLetter.letter,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
    }
    console.error(error);
    throw new Error(error.message || "Failed to update letter progress");
  } finally {
    session.endSession();
    cleanupAudio(filePath); // filePath is now accessible here
  }
};

function cleanupAudio(filePath) {
  if (filePath) {
    try {
      fs.unlinkSync(filePath); // Deletes the file synchronously
      console.log(`Audio file deleted: ${filePath}`);
    } catch (err) {
      console.error(`Failed to delete audio file: ${filePath}`, err.message);
    }
  }
}
function validateSpokenLetter(spokenLetter) {
  if (!spokenLetter || typeof spokenLetter !== "string") {
    throw new Error("Spoken letter (transcribed text) is required");
  }
}
function resolveFilePath(audioFile) {
  return audioFile?.startsWith("http")
    ? audioFile.replace("http://localhost:5500/", "")
    : audioFile ? `uploads/${audioFile}` : null;
}

async function getExpectedLetter(letterId, session) {
  const letter = await Letters.findById(letterId).session(session);
  if (!letter || !letter.letter) throw new Error("Letter not found.");
  return letter;
}

function compareLetters(spoken, expected) {
  return spoken.toLowerCase().trim() === expected.toLowerCase().trim();
}

// Updated Helper Functions
async function updateUserDailyAttempts(userId, levelId, letterId, spokenLetter, correctLetter, isCorrect, session) {
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
      letters_attempts: [],
      words_attempts: [],
      sentences_attempts: [],
    });
  }

  let letterAttempt = userAttempt.letters_attempts.find(
    (attempt) => attempt.letter_id.toString() === letterId && attempt.level_id.toString() === levelId
  );

  if (!letterAttempt) {
    letterAttempt = {
      letter_id: letterId,
      correct_letter: correctLetter,
      spoken_letter: spokenLetter,
      is_correct: isCorrect,
      attempts_number: 1,
      level_id: levelId,
      timestamp: new Date(),
    };
    userAttempt.letters_attempts.push(letterAttempt);
  } else {
    letterAttempt.attempts_number += 1;
    letterAttempt.spoken_letter = spokenLetter;
    letterAttempt.is_correct = isCorrect;
    letterAttempt.timestamp = new Date();
  }

  await userAttempt.save({ session });
  return userAttempt;
}

async function updateExerciseProgress(userId, exerciseId, levelId, letterId, spokenLetter, correctLetter, isCorrect, userAttempt, session) {
  let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId }).session(session);

  if (!progress) {
    progress = new Exercisesprogress({
      user_id: userId,
      exercise_id: exerciseId,
      total_time_spent: 0,
      session_start: new Date(),
      levels: [],
    });
  }

  let levelProgress = progress.levels.find((l) => l.level_id.toString() === levelId.toString());

  if (!levelProgress) {
    levelProgress = {
      level_id: levelId,
      correct_items: [],
      incorrect_items: [],
      games: [],
    };
    progress.levels.push(levelProgress);
  }

  if (isCorrect) {
    const incorrectIndex = levelProgress.incorrect_items.findIndex((l) => l === correctLetter);
    if (incorrectIndex !== -1) levelProgress.incorrect_items.splice(incorrectIndex, 1);

    if (!levelProgress.correct_items.includes(correctLetter)) {
      levelProgress.correct_items.push(correctLetter);
    }
  } else {
    if (!levelProgress.incorrect_items.includes(correctLetter)) {
      levelProgress.incorrect_items.push(correctLetter);
    }
  }

  const totalItems = levelProgress.correct_items.length + levelProgress.incorrect_items.length;
  levelProgress.accuracy_percentage = totalItems > 0 ? (levelProgress.correct_items.length / totalItems) * 100 : 0;
  const timeSpent = 0;
  progress.total_time_spent += timeSpent || 0;
  await progress.save({ session });
  return progress;
}

async function updateOverallProgress(userId, exerciseId, letterId, spokenLetter, correctLetter, isCorrect, timeSpent, session) {
  let overall = await OverallProgress.findOne({ user_id: userId }).session(session);

  if (!overall) {
    overall = new OverallProgress({
      user_id: userId,
      progress_by_exercise: [],
      overall_stats: {
        total_time_spent: timeSpent || 0,
        combined_accuracy: isCorrect ? 100 : 0,
        average_score_all: 0,
      },
    });
  }

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

  const stats = exerciseProgress.stats;

  // First, remove the letter from both correct and incorrect lists (to avoid duplicates)
  stats.total_correct.items = stats.total_correct.items.filter((l) => l !== correctLetter);
  stats.total_incorrect.items = stats.total_incorrect.items.filter((l) => l !== correctLetter);

  // Check if this letter has already been attempted (after cleanup)
  const alreadyAttempted =
    stats.total_correct.items.includes(correctLetter) ||
    stats.total_incorrect.items.includes(correctLetter);

  // Add to the appropriate list based on correctness
  if (isCorrect) {
    stats.total_correct.items.push(correctLetter);
  } else {
    stats.total_incorrect.items.push(correctLetter);
  }

  // Count as a new unique attempt only if not already attempted
  if (!alreadyAttempted) {
    stats.total_items_attempted += 1;
  }

  // Update counts and accuracy
  stats.total_correct.count = stats.total_correct.items.length;
  stats.total_incorrect.count = stats.total_incorrect.items.length;

  stats.accuracy_percentage = stats.total_items_attempted > 0
    ? (stats.total_correct.count / stats.total_items_attempted) * 100
    : 0;

  // Time tracking
  stats.time_spent_seconds += timeSpent || 0;

  // Update overall progress (combined)
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
