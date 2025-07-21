import mongoose from 'mongoose';
import Parents from '../models/Parents.js';
import Users from '../models/Users.js';
import DailyAttemptTracking from '../models/DailyAttemptTracking.js';
import OverallProgress from '../models/OverallProgress.js';
import { emailQueue } from './emailQueue.js';

export const weeklyReportJob = async () => {
  try {
    // Convert the string ID to a MongoDB ObjectId
    const targetParentId = new mongoose.Types.ObjectId('67d02d5cc1b7b3a83eb93505');
    
    // Find only the parent with this specific ID
    const parents = await Parents.find({ _id: targetParentId }).populate('linkedChildren');

    if (parents.length === 0) {
      console.log(`No parent found with ID 67d02d5cc1b7b3a83eb93505`);
      return;
    }

    // Fix date filtering - set to beginning of day 7 days ago
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    oneWeekAgo.setHours(0, 0, 0, 0); // Set to start of day

    // Also create an end date for better filtering
    const now = new Date();
    now.setHours(23, 59, 59, 999); // Set to end of today

    console.log(`Filtering dates from ${oneWeekAgo.toISOString()} to ${now.toISOString()}`);

    for (const parent of parents) {
      if (!parent.linkedChildren.length) {
        console.log(`Skipping parent ${parent.email} — no linked children.`);
        continue;
      }

      const childrenData = [];
      let hasDataForAtLeastOneChild = false;

      for (const learner of parent.linkedChildren) {
        // Improved date filtering with explicit range
        const dailyAttempts = await DailyAttemptTracking.find({
          user_id: learner._id,
          date: { 
            $gte: oneWeekAgo,
            $lte: now 
          }
        }).sort({ date: 1 }); // Sort by date ascending

        const overallProgress = await OverallProgress.findOne({ user_id: learner._id });

        // Debug logging
        console.log(`Found ${dailyAttempts.length} daily attempts for learner ${learner.name}`);
        dailyAttempts.forEach(attempt => {
          console.log(`- Date: ${attempt.date.toISOString()}, Games: ${attempt.game_attempts?.length || 0}, Words: ${attempt.words_attempts?.length || 0}`);
        });

        if (!dailyAttempts.length && !overallProgress) {
          console.log(`No data for learner ${learner.name} under parent ${parent.email}`);
          continue;
        }

        hasDataForAtLeastOneChild = true;
        
        // Add child data to be processed by worker
        childrenData.push({
          learner: learner.toObject(), // Convert mongoose document to plain object
          dailyAttempts: dailyAttempts.map(attempt => attempt.toObject()),
          overallProgress: overallProgress ? overallProgress.toObject() : null
        });
      }

      if (!hasDataForAtLeastOneChild) {
        console.log(`No data for any learners under parent ${parent.email}`);
        continue;
      }

      // Send email generation job to worker
      const subject = childrenData.length > 1 
        ? `Weekly Reports for Your Children - ${new Date().toDateString()}`
        : `Weekly Report for ${childrenData[0].learner.name} - ${new Date().toDateString()}`;
      
      const text = childrenData.length > 1
        ? `Dear ${parent.name},\n\nPlease find attached the weekly learning reports for your children.\n\nBest regards,\nLexFix App Team`
        : `Dear ${parent.name},\n\nPlease find attached the weekly learning report for ${childrenData[0].learner.name}.\n\nBest regards,\nLexFix App Team`;

      await emailQueue.add("weeklyReport", {
        type: "generateWeeklyReport",
        data: {
          parent: parent.toObject(), // Convert mongoose document to plain object
          childrenData,
          subject,
          text
        }
      });

      console.log(`Queued weekly report generation for ${parent.email} with ${childrenData.length} children`);
    }
  } catch (error) {
    console.error('Error in weeklyReportJob:', error);
  }
};