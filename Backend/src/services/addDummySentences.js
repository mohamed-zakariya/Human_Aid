import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Sentences from "../models/Sentences.js";

dotenv.config(); 

const sentencesData = [
    // Beginner Level Sentences
    { sentence: "هذا كتاب جديد", level: "Beginner" },
    { sentence: "الطالب يذهب إلى المدرسة", level: "Beginner" },
    { sentence: "النافذة مفتوحة", level: "Beginner" },
    { sentence: "أكتب بالقلم", level: "Beginner" },
    { sentence: "الباب مغلق", level: "Beginner" },
  
    // // Intermediate Level Sentences
    // { sentence: "أعيش في مدينة كبيرة.", level: "Intermediate" },
    // { sentence: "الطبيب يعمل في المستشفى.", level: "Intermediate" },
    // { sentence: "سوف أسافر من المطار غداً.", level: "Intermediate" },
    // { sentence: "أدرس في الجامعة كل يوم.", level: "Intermediate" },
    // { sentence: "اشتريت حقيبة جديدة للسفر.", level: "Intermediate" },
  
    // // Advanced Level Sentences
    // { sentence: "حضرت المؤتمر العلمي الدولي الأسبوع الماضي.", level: "Advanced" },
    // { sentence: "الحكومة تطور استراتيجية جديدة للتعليم.", level: "Advanced" },
    // { sentence: "أتعلم برمجة تطبيقات الهاتف الذكي.", level: "Advanced" },
    // { sentence: "حل المعادلات الرياضية المعقدة يتطلب تركيزاً.", level: "Advanced" },
    // { sentence: "اقتصاد البلاد ينمو بشكل ملحوظ هذا العام.", level: "Advanced" }
];

const insertDummyData = async () => {
  try {
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("Database connected...");

    // Clear existing sentences to prevent duplication
    await Sentences.deleteMany({});
    console.log("Existing sentences deleted...");

    // Insert new sentences
    await Sentences.insertMany(sentencesData);
    console.log("Dummy sentences inserted successfully!");

    mongoose.disconnect(); // Close connection
  } catch (error) {
    console.error("Error inserting dummy data:", error);
    mongoose.disconnect();
  }
};

insertDummyData();