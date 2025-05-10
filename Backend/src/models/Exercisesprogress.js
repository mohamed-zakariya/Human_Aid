import mongoose from 'mongoose';
const { Schema, model, Types } = mongoose;

// Sub-schema for games inside progress
const gameProgressSchema = new Schema({
  game_id: { type: Types.ObjectId, ref: 'Exercises.levels.games.game_id', required: true },
  scores: { type: [Number], required: true, default: [] },
}, { _id: false });

// Sub-schema for levels inside progress
const levelProgressSchema = new Schema({
  level_id: { type: Types.ObjectId, ref: 'Exercises.levels.level_id', required: true },
  correct_items: [{ type: String }],
  incorrect_items: [{ type: String }],
  games: [gameProgressSchema]
}, { _id: false });

// Main ExerciseProgress schema
const exercisesProgressSchema = new Schema({
  user_id: { type: Types.ObjectId, ref: 'Users', required: true },
  exercise_id: { type: Types.ObjectId, ref: 'Exercises', required: true },
  total_time_spent: { type: Number, required: true, default: 0 },
  session_start: { type: Date},
  levels: [levelProgressSchema],
}, {
  timestamps: true // Automatically adds createdAt and updatedAt
});

const Exercisesprogress = model('Exercisesprogress', exercisesProgressSchema);
export default Exercisesprogress;
