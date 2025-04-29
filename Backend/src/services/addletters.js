import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Letters from "../models/Letters.js"; // Assuming you have a Letters model

dotenv.config();

// Arabic letters data with color groupings
const lettersData = [
  // Group 1 - Red (ب ت ث ن)
  { letter: "ب", color: "red", group: 1 },
  { letter: "ت", color: "red", group: 1 },
  { letter: "ث", color: "red", group: 1 },
  { letter: "ن", color: "red", group: 1 },

  // Group 2 - Green (ج ح خ)
  { letter: "ج", color: "green", group: 2 },
  { letter: "ح", color: "green", group: 2 },
  { letter: "خ", color: "green", group: 2 },

  // Group 3 - Blue (د ذ ر ز و)
  { letter: "د", color: "blue", group: 3 },
  { letter: "ذ", color: "blue", group: 3 },
  { letter: "ر", color: "blue", group: 3 },
  { letter: "ز", color: "blue", group: 3 },
  { letter: "و", color: "blue", group: 3 },

  // Group 4 - Yellow (س ش ص ض)
  { letter: "س", color: "yellow", group: 4 },
  { letter: "ش", color: "yellow", group: 4 },
  { letter: "ص", color: "yellow", group: 4 },
  { letter: "ض", color: "yellow", group: 4 },

  // Group 5 - Purple (ط ظ)
  { letter: "ط", color: "purple", group: 5 },
  { letter: "ظ", color: "purple", group: 5 },

  // Group 6 - Orange (ع غ)
  { letter: "ع", color: "orange", group: 6 },
  { letter: "غ", color: "orange", group: 6 },

  // Group 7 - Pink (Unique shapes)
  { letter: "ا", color: "pink", group: 7 },
  { letter: "ء", color: "pink", group: 7 },
  { letter: "ه", color: "pink", group: 7 },
  { letter: "م", color: "pink", group: 7 },
  { letter: "ل", color: "pink", group: 7 },
  { letter: "ك", color: "pink", group: 7 },
  { letter: "ف", color: "pink", group: 7 },
  { letter: "ق", color: "pink", group: 7 },
  { letter: "ي", color: "pink", group: 7 },
  { letter: "ى", color: "pink", group: 7 },
];

// Function to insert Arabic letters data
const insertArabicLetters = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("Database connected...");

    // Clear existing letters to prevent duplication
    await Letters.deleteMany({});
    console.log("Existing letters deleted...");

    // Insert new letters
    await Letters.insertMany(lettersData);
    console.log("Arabic letters inserted successfully!");

    // Close the database connection
    await mongoose.disconnect();
  } catch (error) {
    console.error("Error inserting Arabic letters:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

// Call the function to insert letters
insertArabicLetters();