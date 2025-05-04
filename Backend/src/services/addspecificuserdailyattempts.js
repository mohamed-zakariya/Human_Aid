import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import DailyAttemptTracking from "../models/UserDailyAttempts.js";
import ExercisesProgress from "../models/Exercisesprogress.js";

dotenv.config();

const addDummyDailyAttempts = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log("Database connected...");

    // Get the exercise progress we created earlier
    const exerciseProgress = await ExercisesProgress.findOne({
      user_id: "67d82674f9d8db70f401ca1b",
      exercise_id: "67c66a0e3387a31ba1ee4a74"
    }).lean();

    if (!exerciseProgress) {
      throw new Error("Exercise progress not found");
    }

    // Get the first level from progress
    const level = exerciseProgress.levels[0];
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set to start of day

    // Create dummy letter attempts (since correct_items are Arabic letters)
    const letterAttempts = [
      {
        letter_id: new mongoose.Types.ObjectId("681267f975387dfda489074f"), // Generate new ID or use real one
        correct_letter: "ب",
        spoken_letter: "ب",
        is_correct: true,
        attempts_number: 1,
        level_id: level.level_id,
        timestamp: new Date()
      },
      {
        letter_id: new mongoose.Types.ObjectId("681267f975387dfda4890750"), // Generate new ID or use real one
        correct_letter: "ت",
        spoken_letter: "ت",
        is_correct: true,
        attempts_number: 1,
        level_id: level.level_id,
        timestamp: new Date()
      },
      {
        letter_id: new mongoose.Types.ObjectId("681267f975387dfda4890762"), // Generate new ID or use real one
        correct_letter: "ق",
        spoken_letter: "ك", // Incorrect attempt
        is_correct: false,
        attempts_number: 1,
        level_id: level.level_id,
        timestamp: new Date()
      }
    ];

    // Create dummy game attempts from the scores in exercise progress
    const gameAttempts = level.games.map(game => ({
      game_id: game.game_id,
      level_id: level.level_id,
      attempts: game.scores.map(score => ({
        score: score,
        timestamp: new Date()
      }))
    }));

    // Check if daily attempt record already exists for today
    let dailyAttempt = await DailyAttemptTracking.findOne({
      user_id: exerciseProgress.user_id,
      date: today
    });

    if (dailyAttempt) {
      // Update existing record
      dailyAttempt.letters_attempts.push(...letterAttempts);
      dailyAttempt.game_attempts.push(...gameAttempts);
    } else {
      // Create new record
      dailyAttempt = new DailyAttemptTracking({
        user_id: exerciseProgress.user_id,
        date: today,
        letters_attempts: letterAttempts,
        game_attempts: gameAttempts,
        words_attempts: [], // Empty arrays for other types
        sentences_attempts: []
      });
    }

    // Save the daily attempt record
    const result = await dailyAttempt.save();
    console.log("Daily attempts added/updated:", result);

    await mongoose.disconnect();
    console.log("Database disconnected...");
  } catch (error) {
    console.error("Error adding daily attempts:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

// Call the function to add dummy data
addDummyDailyAttempts();