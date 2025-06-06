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

      const attachments = [];
      let hasDataForAtLeastOneChild = false;

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

        hasDataForAtLeastOneChild = true;
        const pdfPath = await generateProgressPDF({
          learner,
          parent,
          dailyAttempts,
          overallProgress
        });

        attachments.push({
          path: pdfPath,
          name: `${learner.name}_Weekly_Report.pdf`
        });
      }

      if (!hasDataForAtLeastOneChild) {
        console.log(`No data for any learners under parent ${parent.email}`);
        continue;
      }

      // Send email with all attachments
      const subject = attachments.length > 1 
        ? `Weekly Reports for Your Children - ${new Date().toDateString()}`
        : `Weekly Report for ${parent.linkedChildren[0].name} - ${new Date().toDateString()}`;
      
      const text = attachments.length > 1
        ? `Dear ${parent.name},\n\nPlease find attached the weekly learning reports for your children.\n\nBest regards,\nLexFix App Team`
        : `Dear ${parent.name},\n\nPlease find attached the weekly learning report for ${parent.linkedChildren[0].name}.\n\nBest regards,\nLexFix App Team`;

      await sendEmailWithAttachment({
        to: parent.email,
        subject,
        text,
        attachments
      });

      console.log(`Sent ${attachments.length} report(s) to ${parent.email}`);
    }
  } catch (error) {
    console.error('Error in weeklyReportJob:', error);
  }
};