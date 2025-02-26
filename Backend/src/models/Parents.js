import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const parentSchema = new Schema({
    name: { type: String, required: true },
    username: { type: String, required: false, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: false },
    phoneNumber: { type: String, required: false },
    nationality: { type: String, required: false },
    birthdate: { type: Date, required: false },
    gender: { type: String, enum: ['male', 'female'], required: true },
    googleId: { type: String, unique: true, sparse: true },
    linkedChildren: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    refreshTokens: [{
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true } // Optional for manual cleanup
    }]
}, { timestamps: true });

const Parents = mongoose.model('Parents', parentSchema);
export default Parents;
