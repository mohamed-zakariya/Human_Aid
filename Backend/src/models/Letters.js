import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const lettersSchema = new Schema ({
    letter: { type: String, required: true },
    color: { type: String, required: true },
    group: { type: String,required: true },
});


const Letters = mongoose.model('Letters',lettersSchema);
export default Letters;