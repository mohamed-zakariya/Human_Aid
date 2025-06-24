import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendScheduledNotifications = onSchedule(
  {
    schedule: "every day 10:00",
    timeZone: "Africa/Cairo", // You can change to your local time zone
  },
  async (event) => {
    const db = admin.firestore();
    const now = new Date();

    console.log(`Running scheduled notification job at ${now.toISOString()}`);

    const usersSnapshot = await db.collection("users").get();

    for (const doc of usersSnapshot.docs) {
      const data = doc.data();
      const token = data.fcmToken;
      const lastOpenedStr = data.lastOpened;

      if (!token || !lastOpenedStr) continue;

      const lastOpened = new Date(lastOpenedStr);
      const inactiveDays = (now.getTime() - lastOpened.getTime()) / (1000 * 60 * 60 * 24);

      if (inactiveDays >= 7) {
        await admin.messaging().send({
          token,
          notification: {
            title: "We miss you!",
            body: "You haven’t opened the app in 7 days. Let’s get back to learning!",
          },
        });
        console.log(`Sent 7-day inactivity notification to ${doc.id}`);
      }

      await admin.messaging().send({
        token,
        notification: {
          title: "Daily Reminder",
          body: "It’s 10AM! Time to learn something new today 📚",
        },
      });
      console.log(`Sent 10AM reminder to ${doc.id}`);
    }
  }
);
