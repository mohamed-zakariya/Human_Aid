import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Stories from "../models/Stories.js";

dotenv.config();

const storiesData = [
  {
    story: "كان هناك أرنب وسلحفاة تسابقا في الغابة.",
    kind: "حيوانات",
    summary: "سباق بين الأرنب السريع والسلحفاة البطيئة.",
    morale: "المثابرة أهم من السرعة."
  },
  {
    story: "ساعد النملة صديقتها في جمع الطعام.",
    kind: "حشرات",
    summary: "تعاون النمل لجمع الطعام.",
    morale: "التعاون قوة."
  }
];

const insertDummyStories = async () => {
  try {
    await mongoose.connect(MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("Database connected...");

    await Stories.deleteMany({});
    console.log("Existing stories deleted...");

    await Stories.insertMany(storiesData);
    console.log("Dummy stories inserted successfully!");

    await mongoose.disconnect();
    console.log("Database disconnected.");
  } catch (error) {
    console.error("Error inserting dummy stories:", error);
    await mongoose.disconnect();
    process.exit(1);
  }
};

insertDummyStories();