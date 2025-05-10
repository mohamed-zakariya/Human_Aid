//src/controllers/sentencesExerciseController.js
import mongoose from "mongoose";
import fs from "fs";
import Sentences from "../models/Sentences.js";
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
  export const updateSentenceProgress = async ({
    userId,
    exerciseId,
    sentence_id,
    sentence_text,
    spoken_sentence,
    is_correct,
    incorrect_words = []
  }) => {
    try {
      const today = new Date();
      const scoreChange = is_correct ? 10 : -5;
  
      // === 1. Update Exercisesprogress ===
      let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId });
      if (!progress) {
        progress = new Exercisesprogress({
          user_id: userId,
          exercise_id: exerciseId,
          exercise_time_spent: [],
          correct_words: [],
          incorrect_words: [],
          sentence_attempts: [],
          accuracy_percentage: 0,
          score: 0,
        });
      }
  
      // Update sentence attempt
      let existingAttempt = progress.sentence_attempts.find(a =>
        a.sentence_id.toString() === sentence_id.toString()
      );
  
      if (existingAttempt) {
        existingAttempt.attempts_number += 1;
        existingAttempt.spoken_sentence = spoken_sentence;
        existingAttempt.is_correct = is_correct;
        if (!is_correct) {
          existingAttempt.incorrect_words = incorrect_words;
        }
      } else {
        progress.sentence_attempts.push({
          sentence_id,
          sentence_text,
          spoken_sentence,
          is_correct,
          incorrect_words,
          attempts_number: 1,
        });
      }
  
      // Update score
      progress.score = (progress.score || 0) + scoreChange;
  
      // Update accuracy
      const correctCount = progress.sentence_attempts.filter(s => s.is_correct).length;
      const totalCount = progress.sentence_attempts.length;
      progress.accuracy_percentage = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
  
      await progress.save();
  
      // === 2. Update OverallProgress ===
      let overall = await OverallProgress.findOne({ user_id: userId });
      if (!overall) {
        overall = new OverallProgress({
          user_id: userId,
          progress_id: progress._id,
          completed_exercises: [],
          total_time_spent: 0,
          average_accuracy: 0,
          total_correct_words: { count: 0, words: [] },
          total_incorrect_words: { count: 0, words: [] },
          rewards: [],
        });
      }
  
      // Add completed exercise if not already there
      if (!overall.completed_exercises.includes(exerciseId)) {
        overall.completed_exercises.push(exerciseId);
      }
  
      // Update correct and incorrect word sets
      if (!is_correct) {
        for (const word of incorrect_words) {
          const wordText = word.incorrect_word?.trim();
          
          if (wordText && !overall.total_incorrect_words.words.includes(wordText)) {
            overall.total_incorrect_words.words.push(wordText);
            overall.total_incorrect_words.count += 1;
          }
        }
      }
  
      overall.average_accuracy = Math.round(progress.accuracy_percentage * 100) / 100;
      overall.last_updated = today;
      await overall.save();
  
      // === 3. Update UserDailyAttempts ===
      const todayOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());
      let daily = await UserDailyAttempts.findOne({
        user_id: userId,
        exercise_id: exerciseId,
        date: todayOnly
      });
  
      if (!daily) {
        daily = new UserDailyAttempts({
          user_id: userId,
          exercise_id: exerciseId,
          date: todayOnly,
          sentences_attempts: [],
          words_attempts: []
        });
      }
  
      let dailySentence = daily.sentences_attempts.find(s =>
        s.sentence_id.toString() === sentence_id.toString()
      );
  
      if (dailySentence) {
        dailySentence.attempts_number += 1;
        dailySentence.spoken_sentence = spoken_sentence;
        dailySentence.is_correct = is_correct;
      } else {
        daily.sentences_attempts.push({
          sentence_id,
          correct_sentence: sentence_text,
          spoken_sentence,
          is_correct,
          attempts_number: 1
        });
      }
  
      await daily.save();
  
      return {
        spokenSentence: spoken_sentence,
        expectedSentence: sentence_text,
        isCorrect: is_correct,
        message: 'Sentence progress updated successfully',
        score: progress.score,
        accuracy: progress.accuracy_percentage
      };
  
    } catch (error) {
      console.error('Error updating sentence progress:', error);
      return {
        spokenSentence: spoken_sentence,
        expectedSentence: sentence_text,
        isCorrect: false,
        message: 'Failed to update sentence progress',
        score: 0,
        accuracy: 0
      };
    }
  };
  