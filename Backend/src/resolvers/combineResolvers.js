import { userResolvers } from './userResolvers.js';
import { parentResolvers } from './parentResolvers.js';
import { speechResolvers } from './wordsExerciseResolver.js';
import { sentencesExerciseResolver } from './sentencesExerciseResolver.js';
import { lettersExerciseResolver } from './lettersExerciseResolver.js';
import { gamesResolver } from './gamesResolver.js';
import { adminResolvers } from './adminResolvers.js';
export const resolvers = [userResolvers, parentResolvers,speechResolvers,sentencesExerciseResolver,lettersExerciseResolver,gamesResolver,adminResolvers];