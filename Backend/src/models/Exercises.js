import mongoose from 'mongoose';
const Schema = mongoose.Schema;

// Sub-schema for games
const gameSchema = new Schema({
    game_id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    arabic_name: { type: String, required: true },
    // instructions: { type: String },
    // arabic_instructions: { type: String }
  });

  // Sub-schema for levels
const levelSchema = new Schema({
    level_id: { type: String, required: true, unique: true },
    level_number: { type: Number, required: true, min: 1, max: 3 }, // 1, 2, or 3
    name: { type: String, required: true }, // e.g., "Beginner", "Intermediate", "Advanced"
    arabic_name: { type: String, required: true }, // e.g., "مبتدئ", "متوسط", "متقدم"
    games: [gameSchema], // Array of games for this level
    // unlock_condition: { type: String },
    // required_score: { type: Number }
  });

const exercisesSchema = new Schema ({
    name: { type: String, required: true },
    arabic_name: { type: String, required: true },
    exercise_type: { type: String,required: true },
    english_description : { type: String,required: true },
    arabic_description: { type: String,required: true },
    levels: [levelSchema], // Array of levels for this exercise
    progress_imageUrl: { type: String },
    exercise_imageUrl: { type: String },
});


const Exercises = mongoose.model('Exercises',exercisesSchema);
export default Exercises;
