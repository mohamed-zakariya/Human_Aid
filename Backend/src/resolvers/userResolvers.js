import { login, signUpAdult, signUpChild, refreshTokenUser, logout,forgotUserPassword,verifyUserOTP,resetUserPassword, deleteChild ,learnerHomePage} from "../controllers/userControllers.js"
import Exercisesprogress from "../models/Exercisesprogress.js";
import Exercises from "../models/Exercises.js";
import Users from "../models/Users.js";
export const userResolvers = {
  Query: {
    users: async () => {
      return await Users.find();
    },
    learnerHomePage: async (_, { userId }) => {
      return await learnerHomePage(userId);
    },    
    checkUserUsernameExists: async (_, { username }) => {
      const user = await Users.findOne({ username });
      return { usernameExists: !!user };
    },
    checkUserEmailExists: async (_, { email }) => {
      const user = await Users.findOne({ email });
      return { emailExists: !!user };
    },
      getLevelsForExercises: async () => {
        try {
          console.log("Fetching exercises with levels");
          const exercises = await Exercises.find().populate('levels.games'); // Populate the nested games inside levels
          return exercises;
        } catch (error) {
          console.error("Error fetching exercises with levels:", error);
          throw new Error("Could not fetch exercises and their levels");
        }
      },
    getLearntWordsbyId: async (_, { userId }) => {
      const learnerProgress = await Exercisesprogress.findOne({ user_id: userId });
    
      if (!learnerProgress) {
          throw new Error(`No progress found for user with ID: ${userId}`);
      }
      return learnerProgress;
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
    deleteChild: async (_, args) => {
      return await deleteChild(args);
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
