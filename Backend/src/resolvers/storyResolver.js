import storyGenerator from '../controllers/storyGeneratorControllers.js';
import generateQuestions from '../controllers/storygenerateQuestionsController.js';
import jobStore from '../utils/jobStore.js';

const storyResolver = {
  Mutation: {
    generateArabicStory: async (_, args) => {
      const jobId = jobStore.createJob();

      setTimeout(async () => {
        try {
          const story = await storyGenerator.generateStory(args);
          jobStore.completeJob(jobId, { story });
        } catch (err) {
          jobStore.failJob(jobId, err.message || 'Unknown error');
        }
      }, 0);

      return { jobId };
    },

    generateQuestions: async (_, { story }) => {
      const jobId = jobStore.createJob();

      setTimeout(async () => {
        try {
          const questions = await generateQuestions.generateQuestionsFromStory(story);
          jobStore.completeJob(jobId, { questions });
        } catch (err) {
          jobStore.failJob(jobId, err.message || 'Unknown error');
        }
      }, 0);

      return { jobId };
    }
  },

  Query: {
    getStoryJobStatus: (_, { jobId }) => {
      const job = jobStore.getJob(jobId);
      if (!job) return { status: 'not_found' };
      return {
        status: job.status,
        story: job.result?.story || null,
        error: job.error || null
      };
    },

    getQuestionsJobStatus: (_, { jobId }) => {
      const job = jobStore.getJob(jobId);
      if (!job) return { status: 'not_found' };
      return {
        status: job.status,
        questions: job.result?.questions || null,
        error: job.error || null
      };
    }
  }
};

export default storyResolver;
