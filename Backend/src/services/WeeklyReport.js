import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { weeklyReportJob } from '../config/weeklyReportJob.js';
import { MONGO_URL } from "../config/envConfig.js";


dotenv.config();

const runJob = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log('MongoDB connected.');

    await weeklyReportJob(); 

    await mongoose.disconnect();
    console.log('MongoDB disconnected. Job complete.');
  } catch (err) {
    console.error('Error running the job:', err);
  }
};

runJob();
