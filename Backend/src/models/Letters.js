import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const formSchema = new Schema({
  form: { type: String, required: true },
  example: { type: String, required: true },
}, { _id: false });

const lettersSchema = new Schema({
  letter: { type: String, required: true },
  color: { type: String, required: true },
  group: { type: String, required: true },
  forms: {
    isolated: [formSchema],
    connected: [formSchema],
    final: [formSchema]
  }
});

const Letters = mongoose.model('Letters', lettersSchema);
export default Letters;
