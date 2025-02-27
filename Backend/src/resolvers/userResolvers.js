import { login, signUpAdult, signUpChild, refreshTokenUser, logout,forgotUserPassword,verifyUserOTP,resetUserPassword } from "../controllers/userControllers.js"

export const userResolvers = {
  Query: {
    users: async () => {
      return await Users.find();
    },
  },
  Mutation: {
    login: async (_, { username, password }) => {
      return await login(username, password);
    },
    signUpAdult: async (_, args) => {
      return await signUpAdult(args);
    },
    signUpChild: async (_, args) => {
      return await signUpChild(args);
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
  },
};
