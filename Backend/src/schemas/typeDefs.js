import {userTypeDefs}from './userSchema.js'
import { parentTypeDefs } from "./parentSchema.js";

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
  ];
