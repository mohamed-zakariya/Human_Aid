import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const userSchema = new Schema({
    name: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    email: { type: String, required: false, unique: true, sparse: true },
    password: { type: String, required: true },
    phoneNumber: { type: String, required: false },
    nationality: { type: String, required: true },
    birthdate: { type: Date, required: true },
    gender: { type: String, enum: ['male', 'female'], required: true },
    role: { type: String, enum: ['adult', 'child'], required: true },
    currentStage: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: false },
    otp: { type: String, default: null },
    otpExpires: { type: Date, default: null },
    lastActiveDate: { type: Date, default: Date.now },
    createdAt: { type: Date, default: Date.now },
    refreshTokens: [{
        token: { type: String, required: true },
        expiresAt: { type: Date, required: true } // Optional for manual cleanup
    }]
}, { timestamps: true });

const Users = mongoose.model('Users', userSchema);
export default Users;
