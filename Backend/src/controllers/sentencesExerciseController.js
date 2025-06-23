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
  try {
    validateSpokenSentence(spokenSentence);

    filePath = resolveFilePath(audioFile); // Assign filePath here
    const expectedSentence = await getExpectedSentence(sentenceId, session);
    const isCorrect = compareSentences(spokenSentence, expectedSentence.sentence);

    const userAttempt = await updateUserDailyAttempts(
      userId,
      levelId,
      sentenceId,
      spokenSentence,
      expectedSentence.sentence,
      isCorrect,
      session
    );

    const progress = await updateExerciseProgress(
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

    const overall = await updateOverallProgress(
      userId,
      exerciseId,
      levelId,
      sentenceId,
      spokenSentence,
      expectedSentence.sentence,
      isCorrect,
      timeSpent,
      session
    );

    await session.commitTransaction();
    return {
      spokenSentence,
      expectedSentence: expectedSentence.sentence,
      isCorrect,
      message: isCorrect ? "Correct!" : "Try again!",
      score: progress.score,
      accuracy: progress.accuracy_percentage,
    };
  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
    }
    console.error(error);
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
  const sentence = await Sentences.findById(sentenceId).session(session);
  if (!sentence || !sentence.sentence) throw new Error("Sentence not found.");
  return sentence;
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
    const incorrectIndex = levelProgress.incorrect_items.findIndex((s) => s === correctSentence);
    if (incorrectIndex !== -1) levelProgress.incorrect_items.splice(incorrectIndex, 1);

    if (!levelProgress.correct_items.includes(correctSentence)) {
      levelProgress.correct_items.push(correctSentence);
    }
  } else {
    if (!levelProgress.incorrect_items.includes(correctSentence)) {
      levelProgress.incorrect_items.push(correctSentence);
    }
  }

  const totalItems = levelProgress.correct_items.length + levelProgress.incorrect_items.length;
  levelProgress.accuracy_percentage = totalItems > 0 ? (levelProgress.correct_items.length / totalItems) * 100 : 0;
const timeSpent = 0;
  progress.total_time_spent += timeSpent || 0;
  await progress.save({ session });
  return progress;
}

async function updateOverallProgress(userId, exerciseId, levelId, sentenceId, spokenSentence, correctSentence, isCorrect, timeSpent, session) {
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

  // First, clean up old state by removing the sentence from both lists
  stats.total_correct.items = stats.total_correct.items.filter((s) => s !== correctSentence);
  stats.total_incorrect.items = stats.total_incorrect.items.filter((s) => s !== correctSentence);

  // Then, check if it was already attempted
  const alreadyAttempted =
    stats.total_correct.items.includes(correctSentence) ||
    stats.total_incorrect.items.includes(correctSentence);

  // Add sentence to the appropriate list
  if (isCorrect) {
    stats.total_correct.items.push(correctSentence);
  } else {
    stats.total_incorrect.items.push(correctSentence);
  }

  // Count as a new attempt only if it's a unique sentence
  if (!alreadyAttempted) {
    stats.total_items_attempted += 1;
  }

  // Update counts and accuracy
  stats.total_correct.count = stats.total_correct.items.length;
  stats.total_incorrect.count = stats.total_incorrect.items.length;

  stats.accuracy_percentage = stats.total_items_attempted > 0
    ? (stats.total_correct.count / stats.total_items_attempted) * 100
    : 0;

  // Add time spent
  stats.time_spent_seconds += timeSpent || 0;

  // Aggregate overall stats
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



  // export const updateSentenceProgress = async ({
  //   userId,
  //   exerciseId,
  //   sentence_id,
  //   sentence_text,
  //   spoken_sentence,
  //   is_correct,
  //   incorrect_words = []
  // }) => {
  //   try {
  //     const today = new Date();
  //     const scoreChange = is_correct ? 10 : -5;
  
  //     // === 1. Update Exercisesprogress ===
  //     let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });
  //     if (!progress) {
  //       progress = new Exercisesprogress({
  //         user_id: userId,
  //         exercise_id: exerciseId,
  //         exercise_time_spent: [],
  //         correct_words: [],
  //         incorrect_words: [],
  //         sentence_attempts: [],
  //         accuracy_percentage: 0,
  //         score: 0,
  //       });
  //     }
  
  //     // Update sentence attempt
  //     let existingAttempt = progress.sentence_attempts.find(a =>
  //       a.sentence_id.toString() === sentence_id.toString()
  //     );
  
  //     if (existingAttempt) {
  //       existingAttempt.attempts_number += 1;
  //       existingAttempt.spoken_sentence = spoken_sentence;
  //       existingAttempt.is_correct = is_correct;
  //       if (!is_correct) {
  //         existingAttempt.incorrect_words = incorrect_words;
  //       }
  //     } else {
  //       progress.sentence_attempts.push({
  //         sentence_id,
  //         sentence_text,
  //         spoken_sentence,
  //         is_correct,
  //         incorrect_words,
  //         attempts_number: 1,
  //       });
  //     }
  
  //     // Update score
  //     progress.score = (progress.score || 0) + scoreChange;
  
  //     // Update accuracy
  //     const correctCount = progress.sentence_attempts.filter(s => s.is_correct).length;
  //     const totalCount = progress.sentence_attempts.length;
  //     progress.accuracy_percentage = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
  
  //     await progress.save();
  
  //     // === 2. Update OverallProgress ===
  //     let overall = await OverallProgress.findOne({ user_id: userId });
  //     if (!overall) {
  //       overall = new OverallProgress({
  //         user_id: userId,
  //         progress_id: progress._id,
  //         completed_exercises: [],
  //         total_time_spent: 0,
  //         average_accuracy: 0,
  //         total_correct_words: { count: 0, words: [] },
  //         total_incorrect_words: { count: 0, words: [] },
  //         rewards: [],
  //       });
  //     }
  
  //     // Add completed exercise if not already there
  //     if (!overall.completed_exercises.includes(exerciseId)) {
  //       overall.completed_exercises.push(exerciseId);
  //     }
  
  //     // Update correct and incorrect word sets
  //     if (!is_correct) {
  //       for (const word of incorrect_words) {
  //         const wordText = word.incorrect_word?.trim();
          
  //         if (wordText && !overall.total_incorrect_words.words.includes(wordText)) {
  //           overall.total_incorrect_words.words.push(wordText);
  //           overall.total_incorrect_words.count += 1;
  //         }
  //       }
  //     }
  
  //     overall.average_accuracy = Math.round(progress.accuracy_percentage * 100) / 100;
  //     overall.last_updated = today;
  //     await overall.save();
  
  //     // === 3. Update UserDailyAttempts ===
  //     const todayOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  //     let daily = await UserDailyAttempts.findOne({
  //       user_id: userId,
  //       exercise_id: exerciseId,
  //       date: todayOnly
  //     });
  
  //     if (!daily) {
  //       daily = new UserDailyAttempts({
  //         user_id: userId,
  //         exercise_id: exerciseId,
  //         date: todayOnly,
  //         sentences_attempts: [],
  //         words_attempts: []
  //       });
  //     }
  
  //     let dailySentence = daily.sentences_attempts.find(s =>
  //       s.sentence_id.toString() === sentence_id.toString()
  //     );
  
  //     if (dailySentence) {
  //       dailySentence.attempts_number += 1;
  //       dailySentence.spoken_sentence = spoken_sentence;
  //       dailySentence.is_correct = is_correct;
  //     } else {
  //       daily.sentences_attempts.push({
  //         sentence_id,
  //         correct_sentence: sentence_text,
  //         spoken_sentence,
  //         is_correct,
  //         attempts_number: 1
  //       });
  //     }
  
  //     await daily.save();
  
  //     return {
  //       spokenSentence: spoken_sentence,
  //       expectedSentence: sentence_text,
  //       isCorrect: is_correct,
  //       message: 'Sentence progress updated successfully',
  //       score: progress.score,
  //       accuracy: progress.accuracy_percentage
  //     };
  
  //   } catch (error) {
  //     console.error('Error updating sentence progress:', error);
  //     return {
  //       spokenSentence: spoken_sentence,
  //       expectedSentence: sentence_text,
  //       isCorrect: false,
  //       message: 'Failed to update sentence progress',
  //       score: 0,
  //       accuracy: 0
  //     };
  //   }
  // };
  