import { login, signUpAdult, signUpChild, refreshTokenUser, logout } from "../controllers/userControllers.js"

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
      console.log(args.child);
      return await signUpChild(args.child);
    },
    refreshTokenUser: async (_, { refreshToken }) => {
      return await refreshTokenUser(refreshToken);
    },
    logout: async (_, { refreshToken }) => {   // ✅ Added GraphQL logout mutation
      return await logout(refreshToken);
    },
  },
};
