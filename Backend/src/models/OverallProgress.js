import mongoose from 'mongoose';
const { Schema, model, Types } = mongoose;

// Sub-schema for statistics per exercise
const statsSchema = new Schema({
  total_correct: {
    count: { type: Number, required: true, default: 0 },
    items: [{ type: String }], // list of correct words/letters/sentences
  },
  total_incorrect: {
    count: { type: Number, required: true, default: 0 },
    items: [{ type: String }] // list of incorrect words/letters/sentences
  },
  total_items_attempted: { type: Number, required: true, default: 0 },
  accuracy_percentage: { type: Number, required: true, min: 0, max: 100 },
  average_game_score: { type: Number, required: true, default: 0 },
  time_spent_seconds: { type: Number, required: true, default: 0 },
  progress_percentage: { type: Number, default: 0 ,min:0, max: 100},
}, { _id: false });

// Sub-schema for individual exercise progress
const exerciseProgressSchema = new Schema({
  exercise_id: { type: Types.ObjectId, ref: 'Exercises', required: true },
  stats: { type: statsSchema, required: true }
}, { _id: false });

// Sub-schema for overall stats
const overallStatsSchema = new Schema({
  total_time_spent: { type: Number, required: true, default: 0 },
  combined_accuracy: { type: Number, required: true, min: 0, max: 100 },
  average_score_all: { type: Number, required: true, default: 0 }
}, { _id: false });

// Main schema for OverallProgress
const overallProgressSchema = new Schema({
  user_id: { type: Types.ObjectId, ref: 'Users', required: true },
  progress_by_exercise: [exerciseProgressSchema],
  overall_stats: { type: overallStatsSchema, required: true }
}, {
  timestamps: true // adds createdAt and updatedAt
});

const OverallProgress = model('OverallProgress', overallProgressSchema);
export default OverallProgress;
