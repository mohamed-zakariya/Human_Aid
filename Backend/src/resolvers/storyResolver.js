import storyGenerator from '../controllers/storyGeneratorControllers.js';
import  generateQuestions  from '../controllers/storygenerateQuestionsController.js';
const storyResolver = {
  Mutation: {
    generateArabicStory: async (_, args) => {
      return await storyGenerator.generateStory(args);
    },
    generateQuestions: async (_, { story }) => {
      return await generateQuestions.generateQuestionsFromStory(story);
    }
  }
};
export default storyResolver;
