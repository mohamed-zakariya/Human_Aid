// queues/emailQueue.js
import { Queue } from "bullmq";
import IORedis from "ioredis";
import dotenv from 'dotenv';

dotenv.config();
const redisUrl = process.env.REDIS_URL;

// Create shared Redis connection configuration
const createRedisConnection = () => {
  return new IORedis(redisUrl, {
    maxRetriesPerRequest: null, // BullMQ requires this
    tls: redisUrl.startsWith("rediss://") ? {} : undefined,
    retryDelayOnFailover: 100,
    enableReadyCheck: false,
    lazyConnect: true,
    reconnectOnError: (err) => {
      const targetError = 'READONLY';
      return err.message.includes(targetError);
    },
    connectTimeout: 10000,
    commandTimeout: 5000,
  });
};

// Create the email queue with enhanced configuration
export const emailQueue = new Queue("emailQueue", {
  connection: createRedisConnection(),
  defaultJobOptions: {
    removeOnComplete: 10, // Keep last 10 completed jobs
    removeOnFail: 5,      // Keep last 5 failed jobs
    attempts: 3,          // Retry failed jobs up to 3 times
    backoff: {
      type: 'exponential',
      delay: 2000,        // Start with 2 second delay, then exponential backoff
    },
    delay: 0,             // No delay by default
  },
});

// Optional: Add queue event listeners for monitoring
emailQueue.on('error', (error) => {
  console.error('❌ Email Queue Error:', error);
});

emailQueue.on('waiting', (job) => {
  console.log(`📬 Email job ${job.id} is waiting`);
});

emailQueue.on('active', (job) => {
  console.log(`🔄 Email job ${job.id} is now active`);
});

emailQueue.on('completed', (job) => {
  console.log(`✅ Email job ${job.id} completed successfully`);
});

emailQueue.on('failed', (job, err) => {
  console.error(`❌ Email job ${job.id} failed:`, err.message);
});

// Utility function to add jobs with better error handling
export const addEmailJob = async (jobType, jobData, options = {}) => {
  try {
    const job = await emailQueue.add(jobType, {
      type: jobType,
      data: jobData,
      timestamp: new Date().toISOString(),
    }, {
      ...options,
      // Override attempts for critical emails
      attempts: options.attempts || (jobType === 'sendOTPEmail' ? 5 : 3),
      // Add job ID for tracking
      jobId: options.jobId || `${jobType}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    });

    console.log(`📧 Email job queued: ${jobType} (ID: ${job.id})`);
    return job;
  } catch (error) {
    console.error(`❌ Failed to queue email job ${jobType}:`, error);
    throw error;
  }
};

// Utility functions for common email operations
export const queueWelcomeEmail = (email, name) => {
  return addEmailJob('sendWelcomeEmail', { email, name });
};

export const queueParentWelcomeEmail = (email, name) => {
  return addEmailJob('sendParentWelcomeEmail', { email, name });
};

export const queueOTPEmail = (email, otp) => {
  return addEmailJob('sendOTPEmail', { email, otp }, { 
    attempts: 5, // OTP emails are critical
    priority: 1  // High priority
  });
};

export const queueWeeklyReport = (parent, childrenData, subject, text) => {
  return addEmailJob('generateWeeklyReport', { 
    parent, 
    childrenData, 
    subject, 
    text 
  }, {
    attempts: 2, // Fewer attempts for heavy jobs
    priority: 5  // Lower priority
  });
};

export const queueInactivityEmail = (email, name, lastActiveDate, recipientType, childName = null) => {
  return addEmailJob('sendInactivityEmail', { 
    email, 
    name, 
    lastActiveDate, 
    recipientType, 
    childName 
  });
};

export const queueEmailWithAttachment = (to, subject, text, attachments) => {
  return addEmailJob('sendEmailWithAttachment', { 
    to, 
    subject, 
    text, 
    attachments 
  });
};

// Graceful shutdown function
export const closeEmailQueue = async () => {
  console.log('Closing email queue...');
  await emailQueue.close();
};

// Health check function
export const getQueueHealth = async () => {
  try {
    const waiting = await emailQueue.getWaiting();
    const active = await emailQueue.getActive();
    const completed = await emailQueue.getCompleted();
    const failed = await emailQueue.getFailed();

    return {
      status: 'healthy',
      counts: {
        waiting: waiting.length,
        active: active.length,
        completed: completed.length,
        failed: failed.length,
      },
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString(),
    };
  }
};