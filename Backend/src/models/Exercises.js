import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const exercisesSchema = new Schema ({
    name: { type: String, required: true },
    exercise_type: { type: String,required: true },
});


const Exercises = mongoose.model('Exercises',exercisesSchema);
export default Exercises;