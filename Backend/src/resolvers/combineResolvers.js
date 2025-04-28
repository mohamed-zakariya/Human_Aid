import { userResolvers } from './userResolvers.js';
import { parentResolvers } from './parentResolvers.js';
import { speechResolvers } from './wordsExerciseResolver.js';
import { sentencesExerciseResolver } from './sentencesExerciseResolver.js';
export const resolvers = [userResolvers, parentResolvers,speechResolvers,sentencesExerciseResolver];