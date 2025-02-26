import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const rewardsSchema = new Schema ({
    achievement_type: { type: String, required: true },
    certificate_name: { type: String, required: false },
    description: { type: String, required: true },
    download_url: { type: String, required: false },
});



const Rewards = mongoose.model('Rewards',rewardsSchema);
export default Rewards;