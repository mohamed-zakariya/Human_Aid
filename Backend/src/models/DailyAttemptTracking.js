import mongoose from 'mongoose';
const { Schema, model, Types } = mongoose;

// Game sub-attempt schema
const gameSubAttemptSchema = new Schema({
  score: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now }
}, { _id: false });

// Game attempt schema
const gameAttemptSchema = new Schema({
  game_id: { type: Types.ObjectId, required: true, ref: 'Exercises.levels.games.game_id' },
  level_id: { type: Types.ObjectId, required: true, ref: 'Exercises.levels.level_id' },
  attempts: [gameSubAttemptSchema]
}, { _id: false });

// Word attempt schema
const wordAttemptSchema = new Schema({
  word_id: { type: Types.ObjectId, required: true, ref: 'Words' },
  correct_word: { type: String, required: true },
  spoken_word: { type: String, required: true },
  is_correct: { type: Boolean, required: true },
  attempts_number: { type: Number, default: 1 },
  level_id: { type: Types.ObjectId, required: true, ref: 'Exercises.levels.level_id' },
  timestamp: { type: Date, default: Date.now }
}, { _id: false });

// Letter attempt schema
const letterAttemptSchema = new Schema({
  letter_id: { type: Types.ObjectId, required: true, ref: 'Letters' },
  correct_letter: { type: String, required: true },
  spoken_letter: { type: String, required: true },
  is_correct: { type: Boolean, required: true },
  attempts_number: { type: Number, default: 1 },
  level_id: { type: Types.ObjectId, required: true, ref: 'Exercises.levels.level_id' },
  timestamp: { type: Date, default: Date.now }
}, { _id: false });

// Sentence attempt schema
const sentenceAttemptSchema = new Schema({
  sentence_id: { type: Types.ObjectId, required: true, ref: 'Sentences' },
  correct_sentence: { type: String, required: true },
  spoken_sentence: { type: String, required: true },
  is_correct: { type: Boolean, required: true },
  attempts_number: { type: Number, default: 1 },
  level_id: { type: Types.ObjectId, required: true, ref: 'Exercises.levels.level_id' },
  timestamp: { type: Date, default: Date.now }
}, { _id: false });


// Main DailyAttemptTracking schema
const dailyAttemptTrackingSchema = new Schema({
  user_id: { type: Types.ObjectId, ref: 'Users', required: true, index: true },
  date: { type: Date, required: true },
  words_attempts: [wordAttemptSchema],
  letters_attempts: [letterAttemptSchema],
  sentences_attempts: [sentenceAttemptSchema],
  game_attempts: [gameAttemptSchema]
}, { timestamps: true });

const DailyAttemptTracking = model('DailyAttemptTracking', dailyAttemptTrackingSchema);
export default DailyAttemptTracking;
