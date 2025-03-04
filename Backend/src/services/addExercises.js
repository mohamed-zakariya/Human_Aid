import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Exercises from "../models/Exercises.js"

dotenv.config();

// Dummy exercises data
const exercisesData = [
  { name: "Words Exercise", exercise_type: "words" },
  { name: "Sentences Exercise", exercise_type: "sentences" },
];

// Function to insert dummy exercises
const insertDummyExercises = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("Database connected...");

    // Clear existing exercises to prevent duplication
    await Exercises.deleteMany({});
    console.log("Existing exercises deleted...");

    // Insert new exercises
    await Exercises.insertMany(exercisesData);
    console.log("Dummy exercises inserted successfully!");

    // Close the database connection
    mongoose.disconnect();
  } catch (error) {
    console.error("Error inserting dummy exercises:", error);
    mongoose.disconnect();
  }
};

// Call the function to insert dummy exercises
insertDummyExercises();