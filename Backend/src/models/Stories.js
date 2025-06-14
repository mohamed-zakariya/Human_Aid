import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const storiesSchema = new Schema({
    story: { type: String, required: true },
    kind : { type: String, required: true },
    summary: { type: String, required: true },
    morale: { type: String, required: true },
});
const Stories = mongoose.model('Stories',storiesSchema);
export default Stories;