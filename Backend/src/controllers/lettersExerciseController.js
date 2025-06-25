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
  
  console.log("🚀 Starting updateLetterProgress with:", {
    userId, exerciseId, letterId, levelId, spokenLetter, timeSpent
  });
  
  try {
    validateSpokenLetter(spokenLetter);

    const filePath = resolveFilePath(audioFile);
    console.log("📁 Resolved file path:", filePath);
    
    const expectedLetter = await getExpectedLetter(letterId, session);
    console.log("📝 Expected letter:", expectedLetter);
    
    const isCorrect = compareLetters(spokenLetter, expectedLetter.letter);
    console.log("✅ Is correct:", isCorrect, "| Spoken:", spokenLetter, "| Expected:", expectedLetter.letter);

    // Update Daily Attempts
    console.log("📊 Updating DailyAttemptTracking...");
    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      letterId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      session
    );
    console.log("✅ DailyAttemptTracking updated successfully");

    // Update Exercise Progress
    console.log("📈 Updating ExerciseProgress...");
    const exerciseProgressResult = await updateExerciseProgress(
      userId,
      exerciseId,
      letterId,
      levelId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      userAttempt,
      session
    );
    console.log("✅ ExerciseProgress updated:", {
      levelProgressCount: exerciseProgressResult.levelProgress?.correct_items?.length || 0,
      correctItems: exerciseProgressResult.levelProgress?.correct_items || []
    });

    // Update Overall Progress AFTER exercise progress is saved
    console.log("🎯 Updating OverallProgress...");
    const overall = await updateOverallProgress(
      userId,
      exerciseId,
      letterId,
      spokenLetter,
      expectedLetter.letter,
      isCorrect,
      timeSpent,
      exerciseProgressResult.updatedProgress, // Pass the updated progress
      session
    );
    console.log("✅ OverallProgress updated:", {
      totalCorrect: overall.exerciseStats?.total_correct?.count || 0,
      totalAttempted: overall.exerciseStats?.total_items_attempted || 0
    });

    // Commit transaction
    await session.commitTransaction();
    console.log("🎉 Transaction committed successfully");
    
    return {
      spokenLetter,
      expectedLetter: expectedLetter.letter,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
      console.log("❌ Transaction aborted due to error");
    }
    console.error("💥 Error in updateLetterProgress:", error);
    throw new Error(error.message || "Failed to update progress");
  } finally {
    session.endSession();
    
    try {
      if (audioFile) {
        const filePath = resolveFilePath(audioFile);
        cleanupAudio(filePath);
      }
    } catch (cleanupError) {
      console.warn("⚠️ Audio cleanup failed:", cleanupError.message);
    }
  }
};
// Updated updateExerciseProgress function for letters
async function updateExerciseProgress(
  userId,
  exerciseId,
  letterId,
  levelId,
  spokenLetter,
  correctLetter,
  isCorrect,
  userAttempt,
  session
) {
  console.log("🔍 updateExerciseProgress called with:", {
    userId, exerciseId, letterId, levelId, correctLetter, isCorrect
  });

  let progress = await Exercisesprogress.findOne({ 
    user_id: userId, 
    exercise_id: exerciseId 
  }).session(session);

  console.log("📋 Found existing progress:", !!progress);

  if (!progress) {
    console.log("🆕 Creating new exercise progress");
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
  console.log("🎚️ Found existing level progress:", !!levelProgress);

  if (!levelProgress) {
    console.log("🆕 Creating new level progress");
    levelProgress = {
      level_id: levelId,
      correct_items: [],
      incorrect_items: [],
      games: [],
      progress_percentage: 0
    };
    progress.levels.push(levelProgress);
  }

  console.log("📊 Before update - Correct items:", levelProgress.correct_items.length, levelProgress.correct_items);
  console.log("📊 Before update - Incorrect items:", levelProgress.incorrect_items.length, levelProgress.incorrect_items);

  if (isCorrect) {
    console.log("✅ Processing correct answer");
    
    // Remove from incorrect items if present
    const incorrectIndex = levelProgress.incorrect_items.findIndex(l => l === correctLetter);
    if (incorrectIndex !== -1) {
      levelProgress.incorrect_items.splice(incorrectIndex, 1);
      progress.markModified('levels');
      console.log("🗑️ Removed from incorrect items");
    }

    // Add the correct letter if not already included
    const correctLetterExists = levelProgress.correct_items.some(item => item === correctLetter);
    if (!correctLetterExists) {
      levelProgress.correct_items.push(correctLetter);
      // Mark the nested array as modified for Mongoose
      progress.markModified('levels');
      console.log("➕ Added to correct items:", correctLetter);
    } else {
      console.log("ℹ️ Letter already in correct items");
    }

    // Calculate progress_percentage based on total unique letters in collection
    console.log("📊 Calculating progress percentage for letters...");
    const totalUniqueLetters = await Letters.distinct('letter').session(session);
    const totalLettersCount = totalUniqueLetters.length;
    const uniqueCorrect = levelProgress.correct_items.length;
    const percentage = totalLettersCount > 0 ? (uniqueCorrect / totalLettersCount) * 100 : 0;
    levelProgress.progress_percentage = parseFloat(percentage.toFixed(2));
    
    console.log("📊 Progress percentage calculated:", {
      uniqueCorrect,
      totalLettersCount,
      percentage: levelProgress.progress_percentage
    });
  } else {
    console.log("❌ Processing incorrect answer");
    
    // Add the correct letter to incorrect_items if not already present
    const incorrectLetterExists = levelProgress.incorrect_items.includes(correctLetter);
    if (!incorrectLetterExists) {
      levelProgress.incorrect_items.push(correctLetter);
      progress.markModified('levels');
      console.log("➕ Added to incorrect items:", correctLetter);
    } else {
      console.log("ℹ️ Letter already in incorrect items");
    }
  }

  console.log("📊 After update - Correct items:", levelProgress.correct_items.length, levelProgress.correct_items);
  console.log("📊 After update - Incorrect items:", levelProgress.incorrect_items.length, levelProgress.incorrect_items);

  // Time spent logic (kept as original)
  const timeSpent = 0;
  progress.total_time_spent += timeSpent;

  console.log("💾 Saving exercise progress...");
  console.log("💾 About to save with data:", {
    levelId: levelProgress.level_id,
    correctItems: levelProgress.correct_items,
    incorrectItems: levelProgress.incorrect_items,
    progressPercentage: levelProgress.progress_percentage
  });
  await progress.save({ session });
  console.log("✅ Exercise progress saved successfully");
  
  // Verify the save worked
  const savedProgress = await Exercisesprogress.findOne({ 
    user_id: userId, 
    exercise_id: exerciseId 
  }).session(session);
  const savedLevel = savedProgress.levels.find(l => l.level_id.toString() === levelId.toString());
  console.log("🔍 Verification - Saved level data:", {
    correctItems: savedLevel?.correct_items || [],
    incorrectItems: savedLevel?.incorrect_items || [],
    progressPercentage: savedLevel?.progress_percentage || 0
  });

  return {
    levelProgress,
    updatedProgress: progress // Return the updated progress for use in overall progress calculation
  };
}

// Updated updateOverallProgress function for letters
async function updateOverallProgress(userId, exerciseId, letterId, spokenLetter, correctLetter, isCorrect, timeSpent, updatedExerciseProgress, session) {
  console.log("🎯 updateOverallProgress called with:", {
    userId, exerciseId, correctLetter, isCorrect, timeSpent
  });

  let overall = await OverallProgress.findOne({ user_id: userId }).session(session);
  console.log("📋 Found existing overall progress:", !!overall);

  if (!overall) {
    console.log("🆕 Creating new overall progress");
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
  console.log("🏋️ Found existing exercise progress:", !!exerciseProgress);

  if (!exerciseProgress) {
    console.log("🆕 Creating new exercise progress entry");
    exerciseProgress = {
      exercise_id: exerciseId,
      stats: {
        total_correct: { count: 0, items: [] },
        total_incorrect: { count: 0, items: [] },
        total_items_attempted: 0,
        accuracy_percentage: 0,
        average_game_score: 0,
        time_spent_seconds: 0,
        progress_percentage: 0
      }
    };
    overall.progress_by_exercise.push(exerciseProgress);
  }

  const stats = exerciseProgress.stats;
  console.log("📊 Before update - Stats:", {
    correctCount: stats.total_correct.count,
    correctItems: stats.total_correct.items,
    incorrectCount: stats.total_incorrect.count,
    totalAttempted: stats.total_items_attempted
  });

  // Check if this letter was already attempted today
  const alreadyAttempted = stats.total_correct.items.includes(correctLetter) || 
                          stats.total_incorrect.items.includes(correctLetter);
  console.log("🔍 Was already attempted:", alreadyAttempted);

  // Remove the letter from both lists first (clean slate)
  stats.total_correct.items = stats.total_correct.items.filter(l => l !== correctLetter);
  stats.total_incorrect.items = stats.total_incorrect.items.filter(l => l !== correctLetter);

  // Add to appropriate list based on current result
  if (isCorrect) {
    stats.total_correct.items.push(correctLetter);
    console.log("➕ Added to correct items:", correctLetter);
  } else {
    stats.total_incorrect.items.push(correctLetter);
    console.log("➕ Added to incorrect items:", correctLetter);
  }

  // Mark the nested objects as modified for Mongoose
  overall.markModified('progress_by_exercise');

  // If not already attempted, count as new attempt
  if (!alreadyAttempted) {
    stats.total_items_attempted += 1;
    console.log("📈 Incremented total attempts to:", stats.total_items_attempted);
  }

  // Update correct/incorrect counts
  stats.total_correct.count = stats.total_correct.items.length;
  stats.total_incorrect.count = stats.total_incorrect.items.length;

  // Recalculate accuracy
  stats.accuracy_percentage = stats.total_items_attempted > 0
    ? (stats.total_correct.count / stats.total_items_attempted) * 100
    : 0;

  // Time spent
  stats.time_spent_seconds += timeSpent || 0;

  console.log("📊 After update - Stats:", {
    correctCount: stats.total_correct.count,
    correctItems: stats.total_correct.items,
    incorrectCount: stats.total_incorrect.count,
    totalAttempted: stats.total_items_attempted,
    accuracy: stats.accuracy_percentage
  });

  // Calculate progress percentage using the updated exercise progress
  // For letters, use total unique letters instead of level-based calculation
  if (updatedExerciseProgress) {
    let totalCorrect = 0;

    // Count all correct items across all levels
    for (const level of updatedExerciseProgress.levels) {
      totalCorrect += level.correct_items.length;
    }

    // Get total unique letters in the collection
    const totalUniqueLetters = await Letters.distinct('letter').session(session);
    const totalLettersCount = totalUniqueLetters.length;

    stats.progress_percentage = totalLettersCount > 0
      ? parseFloat(((totalCorrect / totalLettersCount) * 100).toFixed(2))
      : 0;
    
    console.log("📊 Progress percentage calculated:", {
      totalCorrect,
      totalLettersCount,
      progressPercentage: stats.progress_percentage
    });
  }

  // Update overall stats across all exercises
  let totalCorrectGlobal = 0;
  let totalAttemptedGlobal = 0;
  let totalTime = 0;

  for (const ex of overall.progress_by_exercise) {
    totalCorrectGlobal += ex.stats.total_correct.count;
    totalAttemptedGlobal += ex.stats.total_items_attempted;
    totalTime += ex.stats.time_spent_seconds;
  }

  overall.overall_stats.total_time_spent = totalTime;
  overall.overall_stats.combined_accuracy = totalAttemptedGlobal > 0
    ? (totalCorrectGlobal / totalAttemptedGlobal) * 100
    : 0;

  console.log("🌍 Global stats updated:", {
    totalCorrectGlobal,
    totalAttemptedGlobal,
    combinedAccuracy: overall.overall_stats.combined_accuracy
  });

  console.log("💾 Saving overall progress...");
  console.log("💾 About to save overall progress with:", {
    exerciseId: exerciseProgress.exercise_id,
    correctCount: stats.total_correct.count,
    correctItems: stats.total_correct.items,
    totalAttempted: stats.total_items_attempted,
    accuracy: stats.accuracy_percentage
  });
  await overall.save({ session });
  console.log("✅ Overall progress saved successfully");
  
  // Verify the save worked
  const savedOverall = await OverallProgress.findOne({ user_id: userId }).session(session);
  const savedExercise = savedOverall.progress_by_exercise.find(p => p.exercise_id.toString() === exerciseId.toString());
  console.log("🔍 Verification - Saved overall data:", {
    correctCount: savedExercise?.stats?.total_correct?.count || 0,
    correctItems: savedExercise?.stats?.total_correct?.items || [],
    totalAttempted: savedExercise?.stats?.total_items_attempted || 0
  });
  
  return {
    overall,
    exerciseStats: exerciseProgress.stats
  };
}

// Keep all other helper functions the same
function validateSpokenLetter(spokenLetter) {
  console.log("Spoken Letter received:", spokenLetter);
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

async function updateUserDailyAttempts(userId, levelId, letterId, spokenLetter, correctLetter, isCorrect, session) {
  const startOfDay = new Date(); 
  startOfDay.setUTCHours(0, 0, 0, 0);
  const endOfDay = new Date(); 
  endOfDay.setUTCHours(23, 59, 59, 999);

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

  let letterAttempt = userAttempt.letters_attempts.find(attempt =>
    attempt.letter_id.toString() === letterId && attempt.level_id.toString() === levelId
  );

  if (!letterAttempt) {
    letterAttempt = {
      letter_id: letterId,
      correct_letter: correctLetter,
      spoken_letter: spokenLetter,
      is_correct: isCorrect,
      attempts_number: 1,
      level_id: levelId,
      timestamp: new Date()
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

function cleanupAudio(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
    console.log("Audio file cleaned up:", filePath);
  }
}