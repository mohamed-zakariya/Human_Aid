import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import ExercisesProgress from "../models/Exercisesprogress.js";

dotenv.config();

const addDummyExerciseProgress = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log("Database connected...");

    // Create dummy exercise progress data
    const dummyProgress = {
      user_id: new mongoose.Types.ObjectId("67c66c5ce9cba876ceeaffb4"), // Replace with actual user_id
      exercise_id: new mongoose.Types.ObjectId("67c66a0e3387a31ba1ee4a74"), // Replace with actual exercise_id
      total_time_spent: 300, // 5 minutes in seconds
      levels: [
        {
          level_id: new mongoose.Types.ObjectId("681004a0cb31000175a0b1c8"), // Replace with actual level_id
          correct_items: ["ب", "ت"],
          incorrect_items: ["ق"],
          games: [
            {
              game_id: new mongoose.Types.ObjectId("681004a0cb31000175a0b1cc"), // Replace with actual game_id
              scores: [8, 9]
            }
          ]
        }
      ]
    };

    // Insert the dummy data
    const result = await ExercisesProgress.create(dummyProgress);
    console.log("Dummy exercise progress added:", result);

    await mongoose.disconnect();
    console.log("Database disconnected...");
  } catch (error) {
    console.error("Error adding dummy exercise progress:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

// Call the function to add dummy data
addDummyExerciseProgress();