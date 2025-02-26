
import mongoose from 'mongoose';
import { MONGO_URL } from './envConfig.js';

// Connect to MongoDB
export const connectDB = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log('MongoDB connection successful');
  } catch (err) {
    console.error('MongoDB connection failed:', err);
    process.exit(1); // Exit process with failure
  }
};