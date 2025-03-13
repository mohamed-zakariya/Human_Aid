import { userResolvers } from './userResolvers.js';
import { parentResolvers } from './parentResolvers.js';
import { wordsResolvers } from './wordsResolver.js';
import { speechResolvers } from './wordsExerciseResolver.js';
import { exerciseProgressResolvers } from './exerciseProgressResolvers.js';

export const resolvers = [userResolvers, parentResolvers,wordsResolvers,speechResolvers, exerciseProgressResolvers];