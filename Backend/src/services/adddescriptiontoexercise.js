import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Exercises from "../models/Exercises.js";

dotenv.config();
const updateExerciseNames = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log("Database connected...");

    // Update Words Exercise
    const wordsUpdate = await Exercises.updateOne(
      { _id: "67c66a0e3387a31ba1ee4a72" },
      { 
        $rename: { "name": "english_name" },  // Rename field
        $set: { 
          arabic_name: "تمرين الكلمات"  // Add Arabic name
        }
      }
    );

    // Update Sentences Exercise
    const sentencesUpdate = await Exercises.updateOne(
      { _id: "67c66a0e3387a31ba1ee4a73" },
      { 
        $rename: { "name": "english_name" },  // Rename field
        $set: { 
          arabic_name: "تمرين الجمل"  // Add Arabic name
        }
      }
    );

    console.log(`Updated ${wordsUpdate.modifiedCount} document for Words Exercise`);
    console.log(`Updated ${sentencesUpdate.modifiedCount} document for Sentences Exercise`);

    await mongoose.disconnect();
    console.log("Database disconnected...");
  } catch (error) {
    console.error("Error updating exercises:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};
// // Function to update exercises with descriptions
// const updateExercisesWithDescriptions = async () => {
//   try {
//     // Connect to MongoDB
//     await mongoose.connect(MONGO_URL, {
//       useNewUrlParser: true,
//       useUnifiedTopology: true,
//     });

//     console.log("Database connected...");

//     // Update "Words Exercise"
//     const wordsUpdate = await Exercises.updateOne(
//       { _id: "67c66a0e3387a31ba1ee4a72" },
//       { $set: { english_description: ""
//        } }
//     );
//     console.log(`Updated ${wordsUpdate.nModified} document for Words Exercise`);

//     // Update "Sentences Exercise"
//     const sentencesUpdate = await Exercises.updateOne(
//       { _id: "67c66a0e3387a31ba1ee4a73" },
//       { $set: { english_description: "Read a short sentence and answer a simple question about it. This helps improve reading comprehension and focus.",
//         arabic_description: "اقرأ جملة قصيرة ثم أجب عن سؤال بسيط عنها. هذا يساعدك على تحسين الفهم والتركيز"
//        } }
//     );
//     console.log(`Updated ${sentencesUpdate.nModified} document for Sentences Exercise`);

//     // Close the database connection
//     await mongoose.disconnect();
//     console.log("Database disconnected...");
//   } catch (error) {
//     console.error("Error updating exercises:", error);
//     await mongoose.disconnect();
//   }
// };

// Call the function to update exercises
updateExerciseNames();