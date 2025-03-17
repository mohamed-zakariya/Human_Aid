import { login, signUpAdult, signUpChild, refreshTokenUser, logout,forgotUserPassword,verifyUserOTP,resetUserPassword, deleteChild } from "../controllers/userControllers.js"
import Users from "../models/Users.js";
import Exercises from "../models/Exercises.js";
import Exercisesprogress from "../models/Exercisesprogress.js"
export const userResolvers = {
  Query: {
    users: async () => {
      return await Users.find();
    },
    learnerHomePage: async (_, { userId }) => {
      try {
        // Fetch all exercises
        const exercises = await Exercises.find({});
    
        // Fetch all progress records in a single query
        const progressData = await Exercisesprogress.find({
          exercise_id: { $in: exercises.map((e) => e._id) },
          user_id: userId,
        });
    
        // Map progress data by exercise_id for quick lookup
        const progressMap = new Map(progressData.map((p) => [p.exercise_id.toString(), p]));
    
        // Combine exercises with their progress
        const exercisesWithProgress = exercises.map((exercise) => {
          const progress = progressMap.get(exercise._id.toString());
    
          return {
            id: exercise._id,
            name: exercise.name,
            type: exercise.exercise_type,
            progress: progress
              ? {
                  accuracyPercentage: progress.accuracy_percentage,
                  score: progress.score,
                }
              : null,
          };
        });
    
        return exercisesWithProgress;
      } catch (error) {
        console.error('Error fetching learner home page data:', error);
        throw new Error('Failed to fetch learner home page data');
      }
    },    
    checkUserUsernameExists: async (_, { username }) => {
      const user = await Users.findOne({ username });
      return { usernameExists: !!user };
    },
    checkUserEmailExists: async (_, { email }) => {
      const user = await Users.findOne({ email });
      return { emailExists: !!user };
    },
    getLearntWordsbyId: async (_, {userId}) => {
      const learnerProgress = await Exercisesprogress.findOne({userId});
      console.log(learnerProgress);
    }
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
