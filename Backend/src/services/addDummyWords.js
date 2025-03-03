import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Words from "../models/Words.js";

dotenv.config(); 

const wordsData = [
    // Beginner Level Words
    { word: "كتاب", level: "Beginner" },
    { word: "مدرسة", level: "Beginner" },
    { word: "نافذة", level: "Beginner" },
    { word: "قلم", level: "Beginner" },
    { word: "باب", level: "Beginner" },
    { word: "كرسي", level: "Beginner" },
    { word: "تفاحة", level: "Beginner" },
    { word: "ماء", level: "Beginner" },
    { word: "شمس", level: "Beginner" },
    { word: "قمر", level: "Beginner" },
  
    // Intermediate Level Words
    { word: "مدينة", level: "Intermediate" },
    { word: "مستشفى", level: "Intermediate" },
    { word: "محطة", level: "Intermediate" },
    { word: "مطار", level: "Intermediate" },
    { word: "جامعة", level: "Intermediate" },
    { word: "حقيبة", level: "Intermediate" },
    { word: "مكتب", level: "Intermediate" },
    { word: "صحيفة", level: "Intermediate" },
    { word: "سيارة", level: "Intermediate" },
    { word: "حديقة", level: "Intermediate" },
  
    // Advanced Level Words
    { word: "مؤتمر", level: "Advanced" },
    { word: "استراتيجية", level: "Advanced" },
    { word: "برمجة", level: "Advanced" },
    { word: "معادلة", level: "Advanced" },
    { word: "اقتصاد", level: "Advanced" },
    { word: "موسوعة", level: "Advanced" },
    { word: "ابتكار", level: "Advanced" },
    { word: "إلكترونيات", level: "Advanced" },
    { word: "مفاعل", level: "Advanced" },
    { word: "إدارة", level: "Advanced" }
  ];
  

const insertDummyData = async () => {
  try {
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("Database connected...");

    // Clear existing words to prevent duplication
    await Words.deleteMany({});
    console.log("Existing words deleted...");

    // Insert new words
    await Words.insertMany(wordsData);
    console.log("Dummy words inserted successfully!");

    mongoose.disconnect(); // Close connection
  } catch (error) {
    console.error("Error inserting dummy data:", error);
    mongoose.disconnect();
  }
};

insertDummyData();
