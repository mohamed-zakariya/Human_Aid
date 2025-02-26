import { loginParent, signUpParent, refreshTokenParent, logout } from "../controllers/parentController.js";
import Parents from "../models/Parents.js";

export const parentResolvers = {
  Query: {
    parents: async () => {
      return await Parents.find();
    },
  },
  Mutation: {
    loginParent: async (_, { email, password }) => {
      return await loginParent(email, password);
    },
    signUpParent: async (_, args) => {
      return await signUpParent(args.parent);
    },
    refreshTokenParent: async (_, { refreshToken }) => {
      return await refreshTokenParent(refreshToken);
    },
    logout: async (_, { refreshToken }) => {
      return await logout(refreshToken);
    },
  },
};
