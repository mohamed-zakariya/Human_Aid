import { userResolvers } from './userResolvers.js';
import { parentResolvers } from './parentResolvers.js';
import { wordsResolvers } from './wordsResolver.js';
export const resolvers = [userResolvers, parentResolvers,wordsResolvers];