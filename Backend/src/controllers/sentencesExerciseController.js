//src/controllers/sentencesExerciseController.js
import mongoose from "mongoose";
import fs from "fs";
import Sentences from "../models/Sentences.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
import OverallProgress from "../models/OverallProgress.js";

export const updateSentenceProgress = async (userId, exerciseId, levelId, sentenceId, audioFile, spokenSentence, timeSpent) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  let filePath; // Declare filePath outside the try block
  
  console.log("🚀 Starting updateSentenceProgress with:", {
    userId, exerciseId, levelId, sentenceId, spokenSentence, timeSpent
  });
  
  try {
    console.log('🔍 Debug info:', {
      userId,
      exerciseId,
      levelId,
      sentenceId,
      spokenSentence,
      timeSpent
    });

    validateSpokenSentence(spokenSentence);

    filePath = resolveFilePath(audioFile); // Assign filePath here
    console.log("📁 Resolved file path:", filePath);
    
    const expectedSentence = await getExpectedSentence(sentenceId, session);
    console.log("📝 Expected sentence:", expectedSentence);
    
    const isCorrect = compareSentences(spokenSentence, expectedSentence.sentence);
    console.log("✅ Is correct:", isCorrect, "| Spoken:", spokenSentence, "| Expected:", expectedSentence.sentence);

    // Update Daily Attempts
    console.log("📊 Updating DailyAttemptTracking...");
    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      sentenceId,
      spokenSentence,
      expectedSentence.sentence,
      isCorrect,
      session
    );
    console.log("✅ DailyAttemptTracking updated successfully");

    // Update Exercise Progress
    console.log("📈 Updating ExerciseProgress...");
    const exerciseProgressResult = await updateExerciseProgress(
      userId,
      exerciseId,
      levelId,
      sentenceId,
      spokenSentence,
      expectedSentence.sentence,
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
      levelId,
      sentenceId,
      spokenSentence,
      expectedSentence.sentence,
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
      spokenSentence,
      expectedSentence: expectedSentence.sentence,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
      score: exerciseProgressResult.levelProgress?.progress_percentage || 0,
      accuracy: exerciseProgressResult.levelProgress?.accuracy_percentage || 0,
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
      console.log("❌ Transaction aborted due to error");
    }
    console.error('💥 Error in updateSentenceProgress:', error);
    throw new Error(error.message || "Failed to update sentence progress");
  } finally {
    session.endSession();
    cleanupAudio(filePath); // Ensure cleanupAudio is called
  }
};

// Helper Functions
function validateSpokenSentence(spokenSentence) {
  if (!spokenSentence || typeof spokenSentence !== "string") {
    throw new Error("Spoken sentence (transcribed text) is required");
  }
}

function resolveFilePath(audioFile) {
  return audioFile?.startsWith("http")
    ? audioFile.replace("http://localhost:5500/", "")
    : audioFile ? `uploads/${audioFile}` : null;
}

async function getExpectedSentence(sentenceId, session) {
  console.log('🔍 Looking for sentence with ID:', sentenceId);
  
  // Validate ObjectId format
  if (!mongoose.Types.ObjectId.isValid(sentenceId)) {
    console.error('❌ Invalid ObjectId format:', sentenceId);
    throw new Error(`Invalid sentence ID format: ${sentenceId}`);
  }

  const sentence = await Sentences.findById(sentenceId).session(session);
  console.log('📄 Found sentence:', sentence);
  
  if (!sentence) {
    console.error('❌ No sentence found with ID:', sentenceId);
    throw new Error(`Sentence not found with ID: ${sentenceId}`);
  }
  
  // Check what property contains the sentence text
  console.log('📝 Sentence properties:', Object.keys(sentence.toObject ? sentence.toObject() : sentence));
  
  // Try different possible property names for the sentence text
  const sentenceText = sentence.sentence || 
                      sentence.text || 
                      sentence.content || 
                      sentence.sentence_text ||
                      sentence.arabic_text ||
                      sentence.english_text;
  
  if (!sentenceText) {
    console.error('❌ Sentence found but no text content:', sentence);
    throw new Error(`Sentence found but missing text content. Available properties: ${Object.keys(sentence.toObject ? sentence.toObject() : sentence).join(', ')}`);
  }
  
  console.log('✅ Using sentence text:', sentenceText);
  return { ...sentence.toObject(), sentence: sentenceText };
}

function compareSentences(spoken, expected) {
  return spoken.toLowerCase().trim() === expected.toLowerCase().trim();
}

async function updateUserDailyAttempts(userId, levelId, sentenceId, spokenSentence, correctSentence, isCorrect, session) {
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
      sentences_attempts: [],
      words_attempts: [],
      letters_attempts: [],
    });
  }

  let sentenceAttempt = userAttempt.sentences_attempts.find(
    (attempt) => attempt.sentence_id.toString() === sentenceId && attempt.level_id.toString() === levelId
  );

  if (!sentenceAttempt) {
    sentenceAttempt = {
      sentence_id: sentenceId,
      correct_sentence: correctSentence,
      spoken_sentence: spokenSentence,
      is_correct: isCorrect,
      attempts_number: 1,
      level_id: levelId,
      timestamp: new Date(),
    };
    userAttempt.sentences_attempts.push(sentenceAttempt);
  } else {
    sentenceAttempt.attempts_number += 1;
    sentenceAttempt.spoken_sentence = spokenSentence;
    sentenceAttempt.is_correct = isCorrect;
    sentenceAttempt.timestamp = new Date();
  }

  await userAttempt.save({ session });
  return userAttempt;
}

async function updateExerciseProgress(userId, exerciseId, levelId, sentenceId, spokenSentence, correctSentence, isCorrect, userAttempt, session) {
  console.log("🔍 updateExerciseProgress called with:", {
    userId, exerciseId, levelId, sentenceId, correctSentence, isCorrect
  });

  let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId }).session(session);
  console.log("📋 Found existing progress:", !!progress);

  if (!progress) {
    console.log("🆕 Creating new exercise progress");
    progress = new Exercisesprogress({
      user_id: userId,
      exercise_id: exerciseId,
      total_time_spent: 0,
      session_start: new Date(),
      levels: [],
    });
  }

  let levelProgress = progress.levels.find((l) => l.level_id.toString() === levelId.toString());
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
    const incorrectIndex = levelProgress.incorrect_items.findIndex((s) => s === correctSentence);
    if (incorrectIndex !== -1) {
      levelProgress.incorrect_items.splice(incorrectIndex, 1);
      progress.markModified('levels');
      console.log("🗑️ Removed from incorrect items");
    }

    // Add to correct items if not already present
    const correctSentenceExists = levelProgress.correct_items.some(item => item === correctSentence);
    if (!correctSentenceExists) {
      levelProgress.correct_items.push(correctSentence);
      progress.markModified('levels');
      console.log("➕ Added to correct items:", correctSentence);
    } else {
      console.log("ℹ️ Sentence already in correct items");
    }

    // Recalculate progress_percentage - FOLLOWING WORDS CONTROLLER PATTERN
    const sentenceDoc = await Sentences.findOne({ sentence: correctSentence }).session(session);
    const levelName = sentenceDoc?.level;
    console.log("🏷️ Level name:", levelName);

    if (levelName) {
      const totalSentencesInLevel = await Sentences.countDocuments({ level: levelName }).session(session);
      const uniqueCorrect = levelProgress.correct_items.length;
      const percentage = totalSentencesInLevel > 0 ? (uniqueCorrect / totalSentencesInLevel) * 100 : 0;
      levelProgress.progress_percentage = parseFloat(percentage.toFixed(2));
      console.log("📊 Progress percentage calculated:", {
        uniqueCorrect,
        totalSentencesInLevel,
        percentage: levelProgress.progress_percentage
      });
    }
  } else {
    console.log("❌ Processing incorrect answer");
    
    // Add the correct sentence to incorrect_items if not already present
    const incorrectSentenceExists = levelProgress.incorrect_items.includes(correctSentence);
    if (!incorrectSentenceExists) {
      levelProgress.incorrect_items.push(correctSentence);
      progress.markModified('levels');
      console.log("➕ Added to incorrect items:", correctSentence);
    } else {
      console.log("ℹ️ Sentence already in incorrect items");
    }
  }

  console.log("📊 After update - Correct items:", levelProgress.correct_items.length, levelProgress.correct_items);
  console.log("📊 After update - Incorrect items:", levelProgress.incorrect_items.length, levelProgress.incorrect_items);

  const timeSpent = 0;
  progress.total_time_spent += timeSpent || 0;
  
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
    updatedProgress: progress
  };
}

async function updateOverallProgress(userId, exerciseId, levelId, sentenceId, spokenSentence, correctSentence, isCorrect, timeSpent, updatedExerciseProgress, session) {
  console.log("🎯 updateOverallProgress called with:", {
    userId, exerciseId, correctSentence, isCorrect, timeSpent
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
        average_score_all: 0,
      },
    });
  }

  // Find or create the exercise-specific progress entry
  let exerciseProgress = overall.progress_by_exercise.find(
    (p) => p.exercise_id.toString() === exerciseId.toString()
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
      },
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

  // Check if this sentence was already attempted
  const alreadyAttempted = stats.total_correct.items.includes(correctSentence) || 
                          stats.total_incorrect.items.includes(correctSentence);
  console.log("🔍 Was already attempted:", alreadyAttempted);

  // Remove the sentence from both lists first (clean slate)
  stats.total_correct.items = stats.total_correct.items.filter((s) => s !== correctSentence);
  stats.total_incorrect.items = stats.total_incorrect.items.filter((s) => s !== correctSentence);

  // Add to appropriate list based on current result
  if (isCorrect) {
    stats.total_correct.items.push(correctSentence);
    console.log("➕ Added to correct items:", correctSentence);
  } else {
    stats.total_incorrect.items.push(correctSentence);
    console.log("➕ Added to incorrect items:", correctSentence);
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

  // Add time spent
  stats.time_spent_seconds += timeSpent || 0;

  console.log("📊 After update - Stats:", {
    correctCount: stats.total_correct.count,
    correctItems: stats.total_correct.items,
    incorrectCount: stats.total_incorrect.count,
    totalAttempted: stats.total_items_attempted,
    accuracy: stats.accuracy_percentage
  });

  // Calculate progress percentage using the updated exercise progress - FOLLOWING WORDS CONTROLLER PATTERN
  if (updatedExerciseProgress) {
    let totalCorrect = 0;
    let totalSentencesAcrossAllLevels = 0;

    for (const level of updatedExerciseProgress.levels) {
      totalCorrect += level.correct_items.length;

      // Get level name from a sentence in the level
      const sampleSentence = level.correct_items[0] || level.incorrect_items[0];
      if (sampleSentence) {
        const sentenceDoc = await Sentences.findOne({ sentence: sampleSentence }).session(session);
        const levelName = sentenceDoc?.level;

        if (levelName) {
          const sentenceCount = await Sentences.countDocuments({ level: levelName }).session(session);
          totalSentencesAcrossAllLevels += sentenceCount;
        }
      }
    }

    stats.progress_percentage = totalSentencesAcrossAllLevels > 0
      ? parseFloat(((totalCorrect / totalSentencesAcrossAllLevels) * 100).toFixed(2))
      : 0;
    
    console.log("📊 Progress percentage calculated:", {
      totalCorrect,
      totalSentencesAcrossAllLevels,
      progressPercentage: stats.progress_percentage
    });
  }

  // Aggregate overall stats across all exercises
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
    totalAttempted: savedExercise?.stats?.total_items_attempted || 0,
    progressPercentage: savedExercise?.stats?.progress_percentage || 0
  });
  
  return {
    overall,
    exerciseStats: exerciseProgress.stats
  };
}

// Add this function if it doesn't exist
function cleanupAudio(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    try {
      fs.unlinkSync(filePath);
      console.log('🗑️ Audio file cleaned up:', filePath);
    } catch (error) {
      console.error('❌ Failed to cleanup audio file:', error);
    }
  }
}