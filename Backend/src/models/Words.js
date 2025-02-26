import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const wordSchema = new Schema({
    word: { type: String, required: true },
    level: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: true },
});


const Words = mongoose.model('Words',wordSchema);
export default Words;