import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const storiesSchema = new Schema({
    story: { type: String, required: true },
    level: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: true },
    summary: { type: String, required: true },
    questions: [
      {
        question_id: { type: mongoose.Schema.Types.ObjectId, auto: true },
        question_text: { type: String, required: true },
        answers: [
          {
            answer_text: { type: String, required: true },
            is_correct: { type: Boolean, required: true },
          },
        ],
      },
    ],
});
const Stories = mongoose.model('Stories',storiesSchema);
export default Stories;