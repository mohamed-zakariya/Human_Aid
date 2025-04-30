import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Letters from "../models/Letters.js"; // Import your Letters model

dotenv.config();

// Arabic letters data with color groupings
const lettersData = [

  { letter: "ا", color: "white", group: 15 },

  { letter: "ب", color: "red", group: 1 },
  { letter: "ت", color: "red", group: 1 },
  { letter: "ث", color: "red", group: 1 },


  { letter: "ج", color: "green", group: 2 },
  { letter: "ح", color: "green", group: 2 },
  { letter: "خ", color: "green", group: 2 },

  { letter: "د", color: "blue", group: 3 },
  { letter: "ذ", color: "blue", group: 3 },


  { letter: "ر", color: "blue", group: 4 },
  { letter: "ز", color: "blue", group: 4 },

  { letter: "س", color: "yellow", group: 5 },
  { letter: "ش", color: "yellow", group: 5 },

  { letter: "ص", color: "purple", group: 6 },
  { letter: "ض", color: "purple", group: 6 },

  { letter: "ط", color: "purple", group: 7 },
  { letter: "ظ", color: "purple", group: 7 },


  { letter: "ع", color: "orange", group: 8 },
  { letter: "غ", color: "orange", group: 8 },

  { letter: "ف", color: "pink", group: 9 },
  { letter: "ق", color: "pink", group: 9 },

  { letter: "ك", color: "pink", group: 10 },
  { letter: "ل", color: "white", group: 11 },
  { letter: "م", color: "pink", group: 12 },
  { letter: "ن", color: "red", group: 13 },
  { letter: "ه", color: "pink", group: 14 },
  { letter: "و", color: "blue", group: 16 },
  { letter: "ي", color: "pink", group: 17 },
];

// Function to completely refresh the letters data
const refreshArabicLetters = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("Database connected successfully!");

    // Delete ALL existing letters
    await Letters.deleteMany({});
    console.log("All existing letters removed.");

    // Insert the new letters data
    await Letters.insertMany(lettersData);
    console.log("New Arabic letters inserted successfully!");

    // Get count of inserted documents
    const count = await Letters.countDocuments();
    console.log(`Total letters in collection: ${count}`);

    // Close the connection
    await mongoose.disconnect();
    console.log("Database connection closed.");
  } catch (error) {
    console.error("Error during database operation:", error);
    
    // Ensure connection is closed even if error occurs
    if (mongoose.connection.readyState === 1) {
      await mongoose.disconnect();
    }
    process.exit(1);
  }
};

// Execute the function
refreshArabicLetters();