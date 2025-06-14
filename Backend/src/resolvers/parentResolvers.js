import { loginParent, signUpParent, refreshTokenParent, logout,forgotParentPassword,resetParentPassword,verifyParentOTP, getLearnerProgress,getLearnerDailyAttempts,getLearnerOverallProgress, getParentDataById } from "../controllers/parentController.js";
import Parents from "../models/Parents.js";

export const parentResolvers = {
  Query: {
    parents: async () => {
      return await Parents.find();
    },
    checkParentEmailExists: async (_, { email }) => {
      const parent = await Parents.findOne({ email });
      return { emailExists: !!parent };
    },
    getParentChildren: async (_, { parentId }) => {
      const parent = await Parents.findById(parentId).populate('linkedChildren');
      console.log(parent.linkedChildren);
      return  parent.linkedChildren;
    },
    getLearnerProgress: async(_, {parentId}) => {
      return await getLearnerProgress(parentId);
    },
    getLearnerOverallProgress: async(_, {parentId}) => {
      return await getLearnerOverallProgress(parentId);
    },
    
    getLearnerDailyAttempts: async(_, {parentId}) => {
      return await getLearnerDailyAttempts(parentId);
    },
    getParentDataById: async(_, {parentId}) => {
      return await getParentDataById(parentId);
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
