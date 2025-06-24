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
  
  console.log("🚀 Starting updateUserProgress with:", {
    userId, exerciseId, wordId, levelId, spokenWord, timeSpent
  });
  
  try {
    validateSpokenWord(spokenWord);

    const filePath = resolveFilePath(audioFile);
    console.log("📁 Resolved file path:", filePath);
    
    const expectedWord = await getExpectedWord(wordId, session);
    console.log("📝 Expected word:", expectedWord);
    
    const isCorrect = compareWords(spokenWord, expectedWord.word);
    console.log("✅ Is correct:", isCorrect, "| Spoken:", spokenWord, "| Expected:", expectedWord.word);

    // Update Daily Attempts
    console.log("📊 Updating DailyAttemptTracking...");
    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      wordId,
      spokenWord,
      expectedWord.word,
      isCorrect,
      session
    );
    console.log("✅ DailyAttemptTracking updated successfully");

    // Update Exercise Progress
    console.log("📈 Updating ExerciseProgress...");
    const exerciseProgressResult = await updateExerciseProgress(
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
    console.log("✅ ExerciseProgress updated:", {
      levelProgressCount: exerciseProgressResult.levelProgress?.correct_items?.length || 0,
      correctItems: exerciseProgressResult.levelProgress?.correct_items || []
    });

    // Update Overall Progress AFTER exercise progress is saved
    console.log("🎯 Updating OverallProgress...");
    const overall = await updateOverallProgress(
      userId,
      exerciseId,
      wordId,
      spokenWord,
      expectedWord.word,
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
      spokenWord,
      expectedWord: expectedWord.word,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
      console.log("❌ Transaction aborted due to error");
    }
    console.error("💥 Error in updateUserProgress:", error);
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

// Enhanced updateExerciseProgress with detailed logging
async function updateExerciseProgress(
  userId,
  exerciseId,
  wordId,
  levelId,
  spokenWord,
  correctWord,
  isCorrect,
  userAttempt,
  session
) {
  console.log("🔍 updateExerciseProgress called with:", {
    userId, exerciseId, wordId, levelId, correctWord, isCorrect
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
    const incorrectIndex = levelProgress.incorrect_items.findIndex(w => w === correctWord);
    if (incorrectIndex !== -1) {
      levelProgress.incorrect_items.splice(incorrectIndex, 1);
      progress.markModified('levels');
      console.log("🗑️ Removed from incorrect items");
    }

    // Add the correct word if not already included
    const correctWordExists = levelProgress.correct_items.some(item => item === correctWord);
    if (!correctWordExists) {
      levelProgress.correct_items.push(correctWord);
      // Mark the nested array as modified for Mongoose
      progress.markModified('levels');
      console.log("➕ Added to correct items:", correctWord);
    } else {
      console.log("ℹ️ Word already in correct items");
    }

    // Recalculate progress_percentage
    const wordDoc = await Words.findOne({ word: correctWord }).session(session);
    const levelName = wordDoc?.level;
    console.log("🏷️ Level name:", levelName);

    if (levelName) {
      const totalWordsInLevel = await Words.countDocuments({ level: levelName }).session(session);
      const uniqueCorrect = levelProgress.correct_items.length;
      const percentage = totalWordsInLevel > 0 ? (uniqueCorrect / totalWordsInLevel) * 100 : 0;
      levelProgress.progress_percentage = parseFloat(percentage.toFixed(2));
      console.log("📊 Progress percentage calculated:", {
        uniqueCorrect,
        totalWordsInLevel,
        percentage: levelProgress.progress_percentage
      });
    }
  } else {
    console.log("❌ Processing incorrect answer");
    
    // Add the correct word to incorrect_items if not already present
    const incorrectWordExists = levelProgress.incorrect_items.includes(correctWord);
    if (!incorrectWordExists) {
      levelProgress.incorrect_items.push(correctWord);
      progress.markModified('levels');
      console.log("➕ Added to incorrect items:", correctWord);
    } else {
      console.log("ℹ️ Word already in incorrect items");
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

// Fixed updateOverallProgress function
async function updateOverallProgress(userId, exerciseId, wordId, spokenWord, correctWord, isCorrect, timeSpent, updatedExerciseProgress, session) {
  console.log("🎯 updateOverallProgress called with:", {
    userId, exerciseId, correctWord, isCorrect, timeSpent
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

  // Check if this word was already attempted today
  const alreadyAttempted = stats.total_correct.items.includes(correctWord) || 
                          stats.total_incorrect.items.includes(correctWord);
  console.log("🔍 Was already attempted:", alreadyAttempted);

  // Remove the word from both lists first (clean slate)
  stats.total_correct.items = stats.total_correct.items.filter(w => w !== correctWord);
  stats.total_incorrect.items = stats.total_incorrect.items.filter(w => w !== correctWord);

  // Add to appropriate list based on current result
  if (isCorrect) {
    stats.total_correct.items.push(correctWord);
    console.log("➕ Added to correct items:", correctWord);
  } else {
    stats.total_incorrect.items.push(correctWord);
    console.log("➕ Added to incorrect items:", correctWord);
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
  if (updatedExerciseProgress) {
    let totalCorrect = 0;
    let totalWordsAcrossAllLevels = 0;

    for (const level of updatedExerciseProgress.levels) {
      totalCorrect += level.correct_items.length;

      // Get level name from a word in the level
      const sampleWord = level.correct_items[0] || level.incorrect_items[0];
      if (sampleWord) {
        const wordDoc = await Words.findOne({ word: sampleWord }).session(session);
        const levelName = wordDoc?.level;

        if (levelName) {
          const wordCount = await Words.countDocuments({ level: levelName }).session(session);
          totalWordsAcrossAllLevels += wordCount;
        }
      }
    }

    stats.progress_percentage = totalWordsAcrossAllLevels > 0
      ? parseFloat(((totalCorrect / totalWordsAcrossAllLevels) * 100).toFixed(2))
      : 0;
    
    console.log("📊 Progress percentage calculated:", {
      totalCorrect,
      totalWordsAcrossAllLevels,
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
function validateSpokenWord(spokenWord) {
  console.log("Spoken Word received:", spokenWord);
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

async function updateUserDailyAttempts(userId, levelId, wordId, spokenWord, correctWord, isCorrect, session) {
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

function cleanupAudio(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
    console.log("Audio file cleaned up:", filePath);
  }
}