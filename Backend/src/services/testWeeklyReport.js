import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { weeklyReportJob } from '../config/weeklyReportJob.js';
import { MONGO_URL } from "../config/envConfig.js";

// Load environment variables
dotenv.config();

// Connect to your MongoDB
const runJob = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log('MongoDB connected.');

    await weeklyReportJob(); // Run your report generation and email sending

    await mongoose.disconnect();
    console.log('MongoDB disconnected. Job complete.');
  } catch (err) {
    console.error('Error running the job:', err);
  }
};

runJob();
