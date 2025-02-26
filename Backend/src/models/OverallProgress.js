import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const RewardSchema = new mongoose.Schema({
    reward_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Rewards', required: true },
    date_earned: { type: Date, required: true },
  });
const dailyTimeSpentSchema = new Schema({
    date: { type: Date, required: true },
    timeSpent: { type: Number, required: true },
  });
  const overallprogressSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Users', required: true },
    progress_id: { type: mongoose.Schema.Types.ObjectId, ref: 'ExerciseProgress', required: true },
    total_exercises: { type: Number, required: true },
    total_time_spent: { type: Number, required: true }, 
    average_accuracy: { type: Number, required: true },
    total_correct_words: { type: Number, required: true },
    total_incorrect_words: { type: Number, required: true },
    last_updated: { type: Date, default: Date.now },
    dailyTimeSpent: [dailyTimeSpentSchema], 
    rewards: [RewardSchema],
  });
  
const OverallProgress = mongoose.model('OverallProgress',overallprogressSchema);
export default OverallProgress;
