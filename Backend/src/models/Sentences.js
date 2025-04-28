//src/models/sentences.js
import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const sentenceSchema = new Schema({
    sentence: { type: String, required: true },
    level: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: true },
});


const Sentences = mongoose.model('Sentences',sentenceSchema);
export default Sentences;