import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import OverallProgress from "../models/OverallProgress.js"; // Adjust path as needed
import ExercisesProgress from "../models/Exercisesprogress.js";

dotenv.config();

const updateOverallProgress = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log("Database connected...");

    // Get the exercise progress we just created
    const exerciseProgress = await ExercisesProgress.findOne({
      user_id: "67c66c5ce9cba876ceeaffb4",
      exercise_id: "67c66a0e3387a31ba1ee4a74"
    }).lean();

    if (!exerciseProgress) {
      throw new Error("Exercise progress not found");
    }

    // Calculate stats from the exercise progress
    const correctItems = exerciseProgress.levels.flatMap(level => level.correct_items);
    const incorrectItems = exerciseProgress.levels.flatMap(level => level.incorrect_items);
    const totalAttempted = correctItems.length + incorrectItems.length;
    const accuracy = totalAttempted > 0 
      ? Math.round((correctItems.length / totalAttempted) * 100)
      : 0;
    
    const gameScores = exerciseProgress.levels.flatMap(level => 
      level.games.flatMap(game => game.scores)
    );
    const averageScore = gameScores.length > 0 
      ? gameScores.reduce((sum, score) => sum + score, 0) / gameScores.length
      : 0;

    // Prepare the exercise stats
    const exerciseStats = {
      exercise_id: exerciseProgress.exercise_id,
      stats: {
        total_correct: {
          count: correctItems.length,
          items: correctItems
        },
        total_incorrect: {
          count: incorrectItems.length,
          items: incorrectItems
        },
        total_items_attempted: totalAttempted,
        accuracy_percentage: accuracy,
        average_game_score: averageScore,
        time_spent_seconds: exerciseProgress.total_time_spent
      }
    };

    // Check if overall progress exists for this user
    let overallProgress = await OverallProgress.findOne({
      user_id: exerciseProgress.user_id
    });

    if (overallProgress) {
      // Update existing overall progress
      const existingExerciseIndex = overallProgress.progress_by_exercise.findIndex(
        ex => ex.exercise_id.toString() === exerciseProgress.exercise_id.toString()
      );

      if (existingExerciseIndex >= 0) {
        // Update existing exercise stats
        overallProgress.progress_by_exercise[existingExerciseIndex] = exerciseStats;
      } else {
        // Add new exercise stats
        overallProgress.progress_by_exercise.push(exerciseStats);
      }

      // Recalculate overall stats
      await recalculateOverallStats(overallProgress);
      await overallProgress.save();
    } else {
      // Create new overall progress
      overallProgress = new OverallProgress({
        user_id: exerciseProgress.user_id,
        progress_by_exercise: [exerciseStats],
        overall_stats: {
          total_time_spent: exerciseProgress.total_time_spent,
          combined_accuracy: accuracy,
          average_score_all: averageScore
        }
      });
      await overallProgress.save();
    }

    console.log("Overall progress updated:", overallProgress);

    await mongoose.disconnect();
    console.log("Database disconnected...");
  } catch (error) {
    console.error("Error updating overall progress:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

// Helper function to recalculate overall stats
async function recalculateOverallStats(overallProgress) {
  const allExercises = overallProgress.progress_by_exercise;
  
  // Calculate totals across all exercises
  const totalTime = allExercises.reduce((sum, ex) => sum + ex.stats.time_spent_seconds, 0);
  const totalCorrect = allExercises.reduce((sum, ex) => sum + ex.stats.total_correct.count, 0);
  const totalIncorrect = allExercises.reduce((sum, ex) => sum + ex.stats.total_incorrect.count, 0);
  const totalAttempted = totalCorrect + totalIncorrect;
  const combinedAccuracy = totalAttempted > 0 
    ? Math.round((totalCorrect / totalAttempted) * 100)
    : 0;
  
  const allScores = allExercises.flatMap(ex => 
    ex.stats.average_game_score ? [ex.stats.average_game_score] : []
  );
  const averageScoreAll = allScores.length > 0 
    ? allScores.reduce((sum, score) => sum + score, 0) / allScores.length
    : 0;

  // Update overall stats
  overallProgress.overall_stats = {
    total_time_spent: totalTime,
    combined_accuracy: combinedAccuracy,
    average_score_all: averageScoreAll
  };
}

// Call the function to update overall progress
updateOverallProgress();