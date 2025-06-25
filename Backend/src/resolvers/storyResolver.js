import storyGenerator from '../controllers/storyGeneratorControllers.js';
import generateQuestions from '../controllers/storygenerateQuestionsController.js';
import jobStore from '../utils/jobStore.js';


const storyResolver = {
  Mutation: {
    generateArabicStory: async (_, args) => {
      const jobId = jobStore.createJob();

      // Fire-and-forget async processing
      setTimeout(async () => {
        try {
          const story = await storyGenerator.generateStory(args);
          jobStore.completeJob(jobId, { story });
        } catch (err) {
          jobStore.failJob(jobId, err.message || 'Unknown error');
        }
      }, 0);

      return { jobId }; // Return immediately
    },
    generateQuestions: async (_, { story }) => {
      return await generateQuestions.generateQuestionsFromStory(story);
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
    }
  }
};

export default storyResolver;
