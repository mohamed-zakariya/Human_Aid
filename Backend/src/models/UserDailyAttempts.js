import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const userDailyAttemptsSchema = new Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Users', required: true},
    exercise_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Exercises', required: true },
    date: { type: Date,required: true},
    sentences_attempts: [{
        sentence_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Sentences', required: true },
        correct_sentence: { type: String, required: true },
        spoken_sentence: { type: String, required: true },
        is_correct: { type: Boolean, required: true },
        attempts_number: { type: Number, default: 0 },
        //frequency: { type: Number, default: 1 },
    }],
    words_attempts: [{
        word_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Words', required: true },
        correct_word: { type: String, required: true },
        spoken_word: { type: String, required: true },
        is_correct: { type: Boolean, required: true },
        attempts_number: { type: Number, default: 0 },
        //frequency: { type: Number, default: 1 },
    }]
}, { timestamps: true });

const UserDailyAttempts = mongoose.model('UserDailyAttempts', userDailyAttemptsSchema);
export default UserDailyAttempts;
