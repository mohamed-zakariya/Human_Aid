import { login, signUpAdult, signUpChild, refreshTokenUser, logout,forgotUserPassword,verifyUserOTP,resetUserPassword, deleteChild ,learnerHomePage} from "../controllers/userControllers.js"
import Exercisesprogress from "../models/Exercisesprogress.js";
import Exercises from "../models/Exercises.js";
import OverallProgress from "../models/OverallProgress.js";
import Parents from "../models/Parents.js";
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
      learnerProfile: async (_, { userId }) => {
      const user = await Users.findById(userId);
      if (!user) throw new Error("User not found");

      // Get total time spent
      const overallProgress = await OverallProgress.findOne({ user_id: userId });
      const totalTimeSpent = overallProgress?.overall_stats?.total_time_spent || 0;

      // Get parent name if user is a child
      let parentName = null;
      if (user.role === "child") {
        const parent = await Parents.findOne({ linkedChildren: user._id });
        parentName = parent ? parent.name : null;
      }

      return {
        name: user.name,
        username: user.username,
        email: user.role === "adult" ? user.email : null,
        nationality: user.nationality,
        birthdate: user.birthdate,
        gender: user.gender,
        parentName,
        totalTimeSpent,
      };
    },   
  //    getLearnerDataById: async (_, { userId }) => {
  //     console.log(userId);
  //     const user = await Users.findOne({ _id: userId });
  //     console.log(user);
    
  //     if (!user) {
  //         throw new Error(`No progress found for user with ID: ${userId}`);
  //     }
  //     return user;
  // }, 
  
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
    updateUserProfile: async (_, { input }) => {
  const { userId, ...updateFields } = input;

  try {
    const user = await Users.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Update only the provided fields
    Object.keys(updateFields).forEach((key) => {
      if (updateFields[key] !== undefined) {
        user[key] = updateFields[key];
      }
    });

    await user.save();

    return {
      success: true,
      message: "Profile updated successfully",
      updatedUser: user,
    };
  } catch (error) {
    console.error("Error updating profile:", error);
    return {
      success: false,
      message: error.message,
      updatedUser: null,
    };
  }
},
getLearnerDataById: async (_, { userId }) => {
    const user = await Users.findById(userId);
    if (!user) {
      throw new Error(`No user found with ID: ${userId}`);
    }
    user.lastActiveDate = new Date();
    await user.save();
    return user;
  }
  },
};
