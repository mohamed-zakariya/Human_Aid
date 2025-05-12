import { updategamesProgress } from '../controllers/gamesController.js';
export const gamesResolver = {
  Query: {
  },
  Mutation: {
    updategamesProgress: async (_, { userId, exerciseId, levelId, gameId, score}) => {
          return await updategamesProgress(userId, exerciseId, levelId, gameId, score);
        },
  },
};
