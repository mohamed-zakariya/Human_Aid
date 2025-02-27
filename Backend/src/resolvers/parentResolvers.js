import { loginParent, signUpParent, refreshTokenParent, logout,forgotParentPassword,resetParentPassword,verifyParentOTP } from "../controllers/parentController.js";
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
    forgotParentPassword: async (_, { email }) => {
      return await forgotParentPassword(email);
    },
    verifyParentOTP: async (_, { email, otp }) => {
      return await verifyParentOTP(email, otp);
    },
    resetParentPassword: async (_, { token, newPassword }) => {
      return await resetParentPassword(token, newPassword);
    },
  },
};
