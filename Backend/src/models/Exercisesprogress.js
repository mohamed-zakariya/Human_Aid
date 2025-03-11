import mongoose from 'mongoose';
const Schema = mongoose.Schema;


const ExerciseTimeSpentSchema = new mongoose.Schema({
  date: { type: Date, required: true },
  time_spent: { type: Number, required: true },
});

const IncorrectWordSchema = new mongoose.Schema({
  word_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Words', required: true },
  incorrect_word: { type: String, required: true },
  frequency: { type: Number, required: true },
});

const StoryQuestionSchema = new mongoose.Schema({
  question_id: { type: mongoose.Schema.Types.ObjectId},
  is_correct: { type: Boolean, required: true },
});

const SummaryEvaluationSchema = new mongoose.Schema({
  submitted_summary: { type: String, required: true },
  score: { type: Number, required: true },
});

const exerciseprogressSchema = new mongoose.Schema({
    //progress_id: { type: mongoose.Schema.Types.ObjectId, required: true, unique: true },
    exercise_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Exercises', required: true },
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Users', required: true },
    exercise_time_spent: [ExerciseTimeSpentSchema],
    start_time: { type: Date },  // Temporarily store when user starts 
    correct_words: [{ type: String }],
    incorrect_words: [IncorrectWordSchema],
    story: {
        story_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Stories' },
        story_questions: [StoryQuestionSchema],
        summary_evaluation: SummaryEvaluationSchema,
    },
    accuracy_percentage: { type: Number, required: true },
    score: { type: Number, required: true },
});

const Exercisesprogress = mongoose.model('Exercisesprogress',exerciseprogressSchema);
export default Exercisesprogress;