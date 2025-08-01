import {userTypeDefs}from './userSchema.js'
import { parentTypeDefs } from "./parentSchema.js";
import { wordsExerciseTypeDefs } from './wordsExerciseSchema.js';
import { ExercisesprogressTypeDefs } from './exerciseProgressSchema.js';
import { OverallProgressTypeDefs } from './overallProgressSchema.js';
import { sentencesExerciseTypeDefs } from './sentencesExerciseSchema.js';
import { lettersExerciseTypeDefs } from './lettersExerciseSchema.js';
import { gamesTypeDefs } from './gamesSchema.js';
import {adminTypeDefs} from './adminSchema.js';
import {storyGeneratorTypeDefs} from './storySchema.js';
export const baseTypeDefs = `#graphql

type Query {
    _empty: String
  }

  type Mutation {
    _empty: String
  }
`;

export const typeDefs = [
    baseTypeDefs,
    userTypeDefs,
    parentTypeDefs,
    wordsExerciseTypeDefs,
    ExercisesprogressTypeDefs,
    OverallProgressTypeDefs,
    sentencesExerciseTypeDefs,
    storyGeneratorTypeDefs,
    lettersExerciseTypeDefs,
    gamesTypeDefs,
    adminTypeDefs
  ];
