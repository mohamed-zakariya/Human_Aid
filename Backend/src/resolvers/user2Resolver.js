import { login, signUpAdult, signUpChild, refreshTokenUser, logout,forgotUserPassword,verifyUserOTP,resetUserPassword,googleLogin } from "../controllers/userControllers.js"
import Users from "../models/Users.js";
export const userResolvers = {
  Query: {
    users: async () => {
      return await Users.find();
    },
    checkUserUsernameExists: async (_, { username }) => {
      const user = await Users.findOne({ username });
      return { usernameExists: !!user };
    },
  },
  Mutation: {
    login: async (_, { username, password }) => {
      return await login(username, password);
    },
    signUpAdult: async (_, args) => {
      return await signUpAdult(args.adult);
    },
    signUpChild: async (_, args) => {
      console.log(args.child);
      return await signUpChild(args.child);
    },
    refreshTokenUser: async (_, { refreshToken }) => {
      return await refreshTokenUser(refreshToken);
    },
    logout: async (_, { refreshToken }) => {   
      return await logout(refreshToken);
    },
    forgotUserPassword: async (_, { email }) => {
      return await forgotUserPassword(email);
    },
    verifyUserOTP: async (_, { email, otp }) => {
      return await verifyUserOTP(email, otp);
    },
    resetUserPassword: async (_, { token, newPassword }) => {
      return await resetUserPassword(token, newPassword);
    },
    googleLogin: async (_, { idToken }) => {
      return await googleLogin(idToken);
    }
  },
};
