import { userResolvers } from './userResolvers.js';
import { parentResolvers } from './parentResolvers.js';
import { wordsResolvers } from './wordsResolver.js';
import { speechResolvers } from './speechResolver.js';
export const resolvers = [userResolvers, parentResolvers,wordsResolvers,speechResolvers];