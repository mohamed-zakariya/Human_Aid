import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Exercises from "../models/Exercises.js";

dotenv.config();

// Define your own specific ObjectIds
const { ObjectId } = mongoose.Types;

// Updated exercises data with manual _id
const exercisesData = [
  {
    _id: new ObjectId("67c66a0e3387a31ba1ee4a72"), // Words Exercise
    name: "Words Exercise",
    arabic_name: "تمرين الكلمات",
    exercise_type: "words",
    english_description: "Try to say the word you see. You’ll get up to 3 tries. Listen to the correct pronunciation if needed and improve your accuracy.",
    arabic_description: "حاول أن تنطق الكلمة التي تراها. لديك ٣ محاولات. استمع إلى النطق الصحيح لتحسّن أداءك",
    levels: [
      {
        level_id: "words_level_1",
        level_number: 1,
        name: "Beginner",
        arabic_name: "مبتدئ",
        games: [
          { game_id: "words_game_1", name: "Basic Words", arabic_name: "كلمات أساسية" },
          { game_id: "words_game_2", name: "Word Matching", arabic_name: "توصيل الكلمات" }
        ]
      },
      {
        level_id: "words_level_2",
        level_number: 2,
        name: "Intermediate",
        arabic_name: "متوسط",
        games: [
          { game_id: "words_game_3", name: "Intermediate Words", arabic_name: "كلمات متوسطة" },
          { game_id: "words_game_4", name: "Word Categories", arabic_name: "تصنيف الكلمات" }
        ]
      },
      {
        level_id: "words_level_3",
        level_number: 3,
        name: "Advanced",
        arabic_name: "متقدم",
        games: [
          { game_id: "words_game_5", name: "Advanced Words", arabic_name: "كلمات متقدمة" },
          { game_id: "words_game_6", name: "Word Formation", arabic_name: "تكوين الكلمات" }
        ]
      }
    ]
  },
  {
    _id: new ObjectId("67c66a0e3387a31ba1ee4a73"), // Sentences Exercise
    name: "Sentences Exercise",
    arabic_name: "تمرين الجمل",
    exercise_type: "sentences",
    english_description: "Read a short sentence and answer a simple question about it. This helps improve reading comprehension and focus.",
    arabic_description: "اقرأ جملة قصيرة ثم أجب عن سؤال بسيط عنها. هذا يساعدك على تحسين الفهم والتركيز",
    levels: [
      {
        level_id: "sentences_level_1",
        level_number: 1,
        name: "Beginner",
        arabic_name: "مبتدئ",
        games: [
          { game_id: "sentences_game_1", name: "Simple Sentences", arabic_name: "جمل بسيطة" },
          { game_id: "sentences_game_2", name: "Sentence Completion", arabic_name: "إكمال الجمل" }
        ]
      },
      {
        level_id: "sentences_level_2",
        level_number: 2,
        name: "Intermediate",
        arabic_name: "متوسط",
        games: [
          { game_id: "sentences_game_3", name: "Question Answering", arabic_name: "الإجابة على الأسئلة" },
          { game_id: "sentences_game_4", name: "Sentence Ordering", arabic_name: "ترتيب الجمل" }
        ]
      },
      {
        level_id: "sentences_level_3",
        level_number: 3,
        name: "Advanced",
        arabic_name: "متقدم",
        games: [
          { game_id: "sentences_game_5", name: "Complex Sentences", arabic_name: "جمل معقدة" },
          { game_id: "sentences_game_6", name: "Paragraph Understanding", arabic_name: "فهم الفقرات" }
        ]
      }
    ]
  },
  {
    _id: new ObjectId("67c66a0e3387a31ba1ee4a74"), // Letters Exercise
    name: "Letters Exercise",
    arabic_name: "تمرين الحروف",
    exercise_type: "letters",
    english_description: "Learn Arabic letters and their pronunciation. Practice distinguishing similar letters.",
    arabic_description: "تعرف على الحروف العربية وطريقة نطقها. تدرب على تمييز الحروف المتشابهة.",
    levels: [
      {
        level_id: "letters_level_1",
        level_number: 1,
        name: "Beginner",
        arabic_name: "مبتدئ",
        games: [
          { game_id: "letters_game_1", name: "Letter Recognition", arabic_name: "تمييز الحروف" },
          { game_id: "letters_game_2", name: "Basic Pronunciation", arabic_name: "النطق الأساسي" }
        ]
      },
      {
        level_id: "letters_level_2",
        level_number: 2,
        name: "Intermediate",
        arabic_name: "متوسط",
        games: [
          { game_id: "letters_game_3", name: "Similar Letters", arabic_name: "الحروف المتشابهة" },
          { game_id: "letters_game_4", name: "Letter Positions", arabic_name: "مواضع الحروف" }
        ]
      },
      {
        level_id: "letters_level_3",
        level_number: 3,
        name: "Advanced",
        arabic_name: "متقدم",
        games: [
          { game_id: "letters_game_5", name: "Advanced Pronunciation", arabic_name: "النطق المتقدم" },
          { game_id: "letters_game_6", name: "Letter Combinations", arabic_name: "تركيب الحروف" }
        ]
      }
    ]
  }
];

// Function to update exercises
const updateExercises = async () => {
  try {
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("Database connected...");

    await Exercises.deleteMany({});
    console.log("Existing exercises deleted...");

    await Exercises.insertMany(exercisesData);
    console.log("Exercises updated successfully with manual _id!");

    await mongoose.disconnect();
  } catch (error) {
    console.error("Error updating exercises:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

// Run the update
updateExercises();
