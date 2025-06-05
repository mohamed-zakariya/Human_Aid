import mongoose from 'mongoose';
import Parents from '../models/Parents.js';
import Users from '../models/Users.js';
import DailyAttemptTracking from '../models/DailyAttemptTracking.js';
import OverallProgress from '../models/OverallProgress.js';
import { generateProgressPDF } from './pdfGenerator.js';
import { sendEmailWithAttachment } from './emailConfig.js';

export const weeklyReportJob = async () => {
  try {
    const parents = await Parents.find().populate('linkedChildren');

    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    for (const parent of parents) {
      if (!parent.linkedChildren.length) {
        console.log(`Skipping parent ${parent.email} — no linked children.`);
        continue;
      }

      for (const learner of parent.linkedChildren) {
        const dailyAttempts = await DailyAttemptTracking.find({
          user_id: learner._id,
          date: { $gte: oneWeekAgo }
        });

        const overallProgress = await OverallProgress.findOne({ user_id: learner._id });

        if (!dailyAttempts.length && !overallProgress) {
          console.log(`No data for learner ${learner.name} under parent ${parent.email}`);
          continue;
        }

        // 1. Generate PDF
        const pdfPath = await generateProgressPDF({
          learner,
          parent,
          dailyAttempts,
          overallProgress
        });

        // 2. Email parent
        const subject = `Weekly Report for ${learner.name} - ${new Date().toDateString()}`;
        const text = `Dear ${parent.name},\n\nPlease find attached the weekly learning report for ${learner.name}.\n\nBest regards,\nDyslexia App Team`;

        await sendEmailWithAttachment({
          to: parent.email,
          subject,
          text,
          attachmentPath: pdfPath,
          attachmentName: `${learner.name}_Weekly_Report.pdf`
        });

        console.log(`Report sent for learner ${learner.name} to ${parent.email}`);
      }
    }
  } catch (error) {
    console.error('Error in weeklyReportJob:', error);
  }
};
