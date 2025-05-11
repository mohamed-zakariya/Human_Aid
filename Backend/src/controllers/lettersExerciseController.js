import mongoose from "mongoose";
import fs from "fs";
import Words from "../models/Words.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
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

  let exerciseProgress = overall.progress_by_exercise.find((p) => p.exercise_id.toString() === exerciseId.toString());

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

  const alreadyAttempted = stats.total_correct.items.includes(correctLetter) || stats.total_incorrect.items.includes(correctLetter);

  if (!alreadyAttempted) {
    stats.total_items_attempted += 1;
  }

  stats.total_correct.items = stats.total_correct.items.filter((l) => l !== correctLetter);
  stats.total_incorrect.items = stats.total_incorrect.items.filter((l) => l !== correctLetter);

  if (isCorrect) {
    stats.total_correct.items.push(correctLetter);
  } else {
    stats.total_incorrect.items.push(correctLetter);
  }

  stats.total_correct.count = stats.total_correct.items.length;
  stats.total_incorrect.count = stats.total_incorrect.items.length;

  stats.accuracy_percentage = stats.total_items_attempted > 0
    ? (stats.total_correct.count / stats.total_items_attempted) * 100
    : 0;

  stats.time_spent_seconds += timeSpent || 0;

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
  // export const updateLetterProgress = async (userId, exerciseId, letterId, audioFile, spokenLetter, timeSpent) => {
  //   const session = await mongoose.startSession();
  //   session.startTransaction();
  //   try {
  //     console.log("Received spokenLetter:", spokenLetter);
  //     if (!spokenLetter || typeof spokenLetter !== "string") {
  //       throw new Error("Spoken letter (transcribed text) is required");
  //     }
  
  //     const filePath = audioFile?.startsWith("http")
  //       ? audioFile.replace("http://localhost:5500/", "")
  //       : audioFile ? `uploads/${audioFile}` : null;
  
  //     const expectedLetter = await Letters.findById(letterId).session(session);
  //     if (!expectedLetter || !expectedLetter.letter) throw new Error("Letter not found.");
  
  //     const isCorrect = spokenLetter.toLowerCase().trim() === expectedLetter.letter.toLowerCase().trim();
  
  //     // Date range for today's attempt
  //     let startOfDay = new Date(); startOfDay.setUTCHours(0, 0, 0, 0);
  //     let endOfDay = new Date(); endOfDay.setUTCHours(23, 59, 59, 999);
  
  //     // Check or create UserDailyAttempts
  //     let userAttempt = await UserDailyAttempts.findOne({
  //       user_id: userId,
  //       exercise_id: exerciseId,
  //       date: { $gte: startOfDay, $lte: endOfDay },
  //     }).session(session);
  
  //     if (!userAttempt) {
  //       userAttempt = new UserDailyAttempts({
  //         user_id: userId,
  //         exercise_id: exerciseId,
  //         date: new Date(),
  //         letters_attempts: [],
  //         words_attempts: [],
  //         sentences_attempts: [],
  //       });
  //     }
  
  //     let letterAttempt = userAttempt.letters_attempts.find(
  //       (attempt) => attempt.letter_id.toString() === letterId
  //     );
  
  //     if (!letterAttempt) {
  //       letterAttempt = {
  //         letter_id: letterId,
  //         correct_letter: expectedLetter.letter,
  //         spoken_letter: spokenLetter,
  //         is_correct: isCorrect,
  //         attempts_number: 1,
  //       };
  //       userAttempt.letters_attempts.push(letterAttempt);
  //     } else {
  //       letterAttempt.attempts_number += 1;
  //       letterAttempt.spoken_letter = spokenLetter;
  //       letterAttempt.is_correct = isCorrect;
  //     }
  
  //     await userAttempt.save({ session });
  
  //     // Update ExerciseProgress
  //     let progress = await Exercisesprogress.findOne({
  //       user_id: userId,
  //       exercise_id: exerciseId,
  //     }).session(session);
  
  //     if (!progress) {
  //       progress = new Exercisesprogress({
  //         user_id: userId,
  //         exercise_id: exerciseId,
  //         correct_letters: [],
  //         incorrect_letters: [],
  //         score: 0,
  //         accuracy_percentage: 0,
  //       });
  //     }
  
  //     if (isCorrect) {
  //       const incorrectIndex = progress.incorrect_letters.findIndex(l => l.letter_id.toString() === letterId);
  //       if (incorrectIndex !== -1) {
  //         progress.incorrect_letters.splice(incorrectIndex, 1);
  //       }
  
  //       if (!progress.correct_letters.includes(spokenLetter)) {
  //         progress.correct_letters.push(spokenLetter);
  //         progress.score += 5; // You can decide score for letters separately, like 5 instead of 10
  //       }
  //     } else {
  //       if (letterAttempt.attempts_number >= 3) {
  //         let incorrectEntry = progress.incorrect_letters.find(l => l.letter_id.toString() === letterId);
  //         if (incorrectEntry) {
  //           incorrectEntry.frequency += 1;
  //         } else {
  //           progress.incorrect_letters.push({
  //             letter_id: letterId,
  //             correct_letter: expectedLetter.letter,
  //             incorrect_letter: spokenLetter,
  //             frequency: 1,
  //           });
  //         }
  //         progress.score = Math.max(progress.score - 2, 0); // Deduct 2 points for letters maybe?
  //       }
  //     }
  
  //     const totalAttempts = progress.correct_letters.length + progress.incorrect_letters.length;
  //     progress.accuracy_percentage = totalAttempts > 0 ? (progress.correct_letters.length / totalAttempts) * 100 : 0;
  //     await progress.save({ session });
  
  //     // Handle Overall Progress
  //     let overall = await OverallProgress.findOne({ user_id: userId }).session(session);
  //     if (!overall) {
  //       overall = new OverallProgress({
  //         user_id: userId,
  //         progress_id: progress._id,
  //         completed_exercises: [exerciseId],
  //         total_time_spent: timeSpent || 0,
  //         average_accuracy: progress.accuracy_percentage,
  //         total_correct_letters: { count: isCorrect ? 1 : 0, letters: isCorrect ? [expectedLetter.letter] : [] },
  //         total_incorrect_letters: { count: !isCorrect ? 1 : 0, letters: !isCorrect ? [expectedLetter.letter] : [] },
  //       });
  //     } else {
  //       if (!overall.completed_exercises.includes(exerciseId)) {
  //         overall.completed_exercises.push(exerciseId);
  //       }
  
  //       const allExerciseProgress = await Exercisesprogress.find({ user_id: userId }).session(session);
  
  //       let totalTime = 0;
  //       for (const exercise of allExerciseProgress) {
  //         for (const timeEntry of exercise.exercise_time_spent) {
  //           totalTime += timeEntry.time_spent;
  //         }
  //       }
  
  //       overall.total_time_spent = totalTime;
  
  //       if (isCorrect) {
  //         const incorrectIdx = overall.total_incorrect_letters.letters.indexOf(spokenLetter);
  //         if (incorrectIdx !== -1) {
  //           overall.total_incorrect_letters.letters.splice(incorrectIdx, 1);
  //           overall.total_incorrect_letters.count = Math.max(overall.total_incorrect_letters.count - 1, 0);
  //         }
  
  //         if (!overall.total_correct_letters.letters.includes(expectedLetter.letter)) {
  //           overall.total_correct_letters.letters.push(expectedLetter.letter);
  //           overall.total_correct_letters.count += 1;
  //         }
  //       } else {
  //         if (letterAttempt.attempts_number >= 3) {
  //           if (!overall.total_incorrect_letters.letters.includes(expectedLetter.letter)) {
  //             overall.total_incorrect_letters.letters.push(expectedLetter.letter);
  //             overall.total_incorrect_letters.count += 1;
  //           }
  //         }
  //       }
  
  //       const totalLetters = overall.total_correct_letters.count + overall.total_incorrect_letters.count;
  //       overall.average_accuracy = totalLetters > 0 ? (overall.total_correct_letters.count / totalLetters) * 100 : 0;
  //     }
  
  //     overall.last_updated = new Date();
  //     await overall.save({ session });
  
  //     // Commit the transaction
  //     await session.commitTransaction();
  //     session.endSession();
  
  //     if (filePath) {
  //       try { fs.unlinkSync(filePath); }
  //       catch (err) { console.error("Failed to delete audio file:", err.message); }
  //     }
  
  //     return {
  //       spokenLetter,
  //       expectedLetter: expectedLetter.letter,
  //       isCorrect,
  //       score: progress.score,
  //       accuracy: progress.accuracy_percentage,
  //       overall_accuracy: overall.average_accuracy,
  //       message: isCorrect ? "Correct!" : "Try again!",
  //     };
  
  //   } catch (error) {
  //     await session.abortTransaction();
  //     session.endSession();
  //     console.error(error);
  //     throw new Error(error.message || "Failed to update letter progress");
  //   }
  // };
  