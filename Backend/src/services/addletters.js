import mongoose from "mongoose";
import dotenv from "dotenv";
import { MONGO_URL } from "../config/envConfig.js";
import Letters from "../models/Letters.js"; // Import your Letters model

dotenv.config();

// Arabic letters data with color groupings
const lettersData = [
  {
    letter: "ا", color: "white", group: 15,
    forms: {
      isolated: [{ form: "ا", example: "أسد" }],
      connected: [{ form: "ـا", example: "سماء" }],
      final: [{ form: "ـا", example: "رضا" }]
    }
  },
  {
    letter: "ب", color: "red", group: 1,
    forms: {
      isolated: [{ form: "ب", example: "باب" }],
      connected: [{ form: "ـبـ", example: "كتاب" }],
      final: [{ form: "ـب", example: "حب" }]
    }
  },
  {
    letter: "ت", color: "red", group: 1,
    forms: {
      isolated: [{ form: "ت", example: "تفاح" }],
      connected: [{ form: "ـتـ", example: "كتاب" }],
      final: [{ form: "ـت", example: "بيت" }]
    }
  },
  {
    letter: "ث", color: "red", group: 1,
    forms: {
      isolated: [{ form: "ث", example: "ثمر" }],
      connected: [{ form: "ـثـ", example: "مثال" }],
      final: [{ form: "ـث", example: "لبث" }]
    }
  },
  {
    letter: "ج", color: "green", group: 2,
    forms: {
      isolated: [{ form: "ج", example: "جمل" }],
      connected: [{ form: "ـجـ", example: "مجتمع" }],
      final: [{ form: "ـج", example: "خرج" }]
    }
  },
  {
    letter: "ح", color: "green", group: 2,
    forms: {
      isolated: [{ form: "ح", example: "حصان" }],
      connected: [{ form: "ـحـ", example: "محراب" }],
      final: [{ form: "ـح", example: "فتح" }]
    }
  },
  {
    letter: "خ", color: "green", group: 2,
    forms: {
      isolated: [{ form: "خ", example: "خبز" }],
      connected: [{ form: "ـخـ", example: "مخبز" }],
      final: [{ form: "ـخ", example: "ملخ" }]
    }
  },
  {
    letter: "د", color: "blue", group: 3,
    forms: {
      isolated: [{ form: "د", example: "دب" }],
      connected: [{ form: "ـد", example: "يد" }],
      final: [{ form: "ـد", example: "عبد" }]
    }
  },
  {
    letter: "ذ", color: "blue", group: 3,
    forms: {
      isolated: [{ form: "ذ", example: "ذئب" }],
      connected: [{ form: "ـذ", example: "خذ" }],
      final: [{ form: "ـذ", example: "فذ" }]
    }
  },
  {
    letter: "ر", color: "blue", group: 4,
    forms: {
      isolated: [{ form: "ر", example: "رسالة" }],
      connected: [{ form: "ـر", example: "صبر" }],
      final: [{ form: "ـر", example: "قمر" }]
    }
  },
  {
    letter: "ز", color: "blue", group: 4,
    forms: {
      isolated: [{ form: "ز", example: "زرافة" }],
      connected: [{ form: "ـز", example: "وزن" }],
      final: [{ form: "ـز", example: "عز" }]
    }
  },
  {
    letter: "س", color: "yellow", group: 5,
    forms: {
      isolated: [{ form: "س", example: "سماء" }],
      connected: [{ form: "ـسـ", example: "مدرسة" }],
      final: [{ form: "ـس", example: "جلس" }]
    }
  },
  {
    letter: "ش", color: "yellow", group: 5,
    forms: {
      isolated: [{ form: "ش", example: "شمس" }],
      connected: [{ form: "ـشـ", example: "مشروع" }],
      final: [{ form: "ـش", example: "عش" }]
    }
  },
  {
    letter: "ص", color: "purple", group: 6,
    forms: {
      isolated: [{ form: "ص", example: "صقر" }],
      connected: [{ form: "ـصـ", example: "مصر" }],
      final: [{ form: "ـص", example: "نص" }]
    }
  },
  {
    letter: "ض", color: "purple", group: 6,
    forms: {
      isolated: [{ form: "ض", example: "ضوء" }],
      connected: [{ form: "ـضـ", example: "مرض" }],
      final: [{ form: "ـض", example: "أرض" }]
    }
  },
  {
    letter: "ط", color: "purple", group: 7,
    forms: {
      isolated: [{ form: "ط", example: "طائرة" }],
      connected: [{ form: "ـطـ", example: "خطوة" }],
      final: [{ form: "ـط", example: "خط" }]
    }
  },
  {
    letter: "ظ", color: "purple", group: 7,
    forms: {
      isolated: [{ form: "ظ", example: "ظل" }],
      connected: [{ form: "ـظـ", example: "نظام" }],
      final: [{ form: "ـظ", example: "حفظ" }]
    }
  },
  {
    letter: "ع", color: "orange", group: 8,
    forms: {
      isolated: [{ form: "ع", example: "عين" }],
      connected: [{ form: "ـعـ", example: "علم" }],
      final: [{ form: "ـع", example: "منع" }]
    }
  },
  {
    letter: "غ", color: "orange", group: 8,
    forms: {
      isolated: [{ form: "غ", example: "غزال" }],
      connected: [{ form: "ـغـ", example: "مغارة" }],
      final: [{ form: "ـغ", example: "بلغ" }]
    }
  },
  {
    letter: "ف", color: "pink", group: 9,
    forms: {
      isolated: [{ form: "ف", example: "فم" }],
      connected: [{ form: "ـفـ", example: "طفل" }],
      final: [{ form: "ـف", example: "خوف" }]
    }
  },
  {
    letter: "ق", color: "pink", group: 9,
    forms: {
      isolated: [{ form: "ق", example: "قلم" }],
      connected: [{ form: "ـقـ", example: "فقر" }],
      final: [{ form: "ـق", example: "سبق" }]
    }
  },
  {
    letter: "ك", color: "pink", group: 10,
    forms: {
      isolated: [{ form: "ك", example: "كتاب" }],
      connected: [{ form: "ـكـ", example: "مكتب" }],
      final: [{ form: "ـك", example: "فلك" }]
    }
  },
  {
    letter: "ل", color: "white", group: 11,
    forms: {
      isolated: [{ form: "ل", example: "لبن" }],
      connected: [{ form: "ـلـ", example: "كلمة" }],
      final: [{ form: "ـل", example: "فعل" }]
    }
  },
  {
    letter: "م", color: "pink", group: 12,
    forms: {
      isolated: [{ form: "م", example: "موز" }],
      connected: [{ form: "ـمـ", example: "مكتب" }],
      final: [{ form: "ـم", example: "حكم" }]
    }
  },
  {
    letter: "ن", color: "red", group: 13,
    forms: {
      isolated: [{ form: "ن", example: "نار" }],
      connected: [{ form: "ـنـ", example: "منزل" }],
      final: [{ form: "ـن", example: "حزن" }]
    }
  },
  {
    letter: "ه", color: "pink", group: 14,
    forms: {
      isolated: [{ form: "ه", example: "هلال" }],
      connected: [{ form: "ـهـ", example: "جهة" }],
      final: [{ form: "ـه", example: "وجه" }]
    }
  },
  {
    letter: "و", color: "blue", group: 16,
    forms: {
      isolated: [{ form: "و", example: "وردة" }],
      connected: [{ form: "ـو", example: "نمو" }],
      final: [{ form: "ـو", example: "ضوء" }]
    }
  },
  {
    letter: "ي", color: "pink", group: 17,
    forms: {
      isolated: [{ form: "ي", example: "يد" }],
      connected: [{ form: "ـيـ", example: "بيت" }],
      final: [{ form: "ـي", example: "كرسي" }]
    }
  }
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