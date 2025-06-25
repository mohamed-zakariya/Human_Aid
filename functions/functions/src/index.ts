import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendScheduledNotifications = onSchedule(
  {
    schedule: "every day 10:00",
    timeZone: "Africa/Cairo",
  },
  async (event) => {
    const db = admin.firestore();
    const nowUTC = new Date();

    // Adjust now to Africa/Cairo (UTC+3)
    const cairoOffsetHours = 3;
    const nowCairo = new Date(nowUTC.getTime() + cairoOffsetHours * 60 * 60 * 1000);

    console.log(`📅 Running scheduled notification job at ${nowCairo.toISOString()} (Cairo time)`);

    const usersSnapshot = await db.collection("users").get();

    for (const doc of usersSnapshot.docs) {
      const data = doc.data();
      const token = data.fcmToken;
      const lastOpenedStr = data.lastOpened;

      if (!token || !lastOpenedStr) {
        console.log(`⚠️ Skipping ${doc.id} - missing token or lastOpened`);
        continue;
      }

      // Parse lastOpened assuming it's already in Cairo time
      const lastOpened = new Date(`${lastOpenedStr}Z`);

      const inactiveHours = (nowCairo.getTime() - lastOpened.getTime()) / (1000 * 60 * 60);

      console.log(`⏱ User ${doc.id} inactive for ${inactiveHours.toFixed(2)} hours`);

      if (inactiveHours < 0) {
        console.log(`🚫 Skipping ${doc.id} - lastOpened is in the future!`);
        continue;
      }

      // Send inactivity notification if inactive ≥ 7 days (168 hours)
      if (inactiveHours >= 168) {
        await admin.messaging().send({
          token,
          notification: {
            title: "We miss you!",
            body: "You haven’t opened the app in 7 days. Let’s get back to learning!",
          },
        });
        console.log(`✅ Sent 7-day inactivity notification to ${doc.id}`);
      } else {
        console.log(`⏩ Skipped inactivity notification for ${doc.id}`);
      }

      // Always send daily reminder
      await admin.messaging().send({
        token,
        notification: {
          title: "Daily Reminder",
          body: "It’s 10AM! Time to learn something new today 📚",
        },
      });
      console.log(`✅ Sent 10AM reminder to ${doc.id}`);
    }
  }
);
