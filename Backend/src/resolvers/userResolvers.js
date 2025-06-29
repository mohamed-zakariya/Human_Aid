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
getLevelsForExercises: async (_, { userId, exerciseId }) => {
  try {
    // 🧾 No arguments passed → return all exercises with unlocked games
    if (!userId || !exerciseId) {
      console.log("First-time user: fetching all exercises");

      const exercises = await Exercises.find().lean();

      const allExercises = exercises.map(ex => ({
        id: ex._id.toString(),
        ...ex,
        levels: ex.levels.map(level => ({
          ...level,
          progressPercentage: 0,
          games: level.games.map(game => ({
            ...game,
            unlocked: true  // 🔓 unlocked by default for first time
          }))
        }))
      }));

      return allExercises;
    }

    // 🎯 If userId and exerciseId are provided → enrich based on progress
    const exercise = await Exercises.findById(exerciseId).lean();
    if (!exercise) throw new Error("Exercise not found");

    const userProgress = await Exercisesprogress.findOne({
      user_id: userId,
      exercise_id: exerciseId
    }).lean();

    const enrichedLevels = exercise.levels.map(level => {
      const levelProgress = userProgress?.levels.find(lv =>
        lv.level_id.toString() === level._id.toString()
      );

      const progressPercentage = levelProgress?.progress_percentage ?? 0;

      const totalGames = level.games.length;

      const enrichedGames = level.games.map((game, idx) => {
        const unlockThreshold = (100 / totalGames) * idx;
        const unlocked = progressPercentage >= unlockThreshold;
        return { ...game, unlocked };
      });

      return {
        ...level,
        progressPercentage,
        games: enrichedGames
      };
    });

    return [{
      id: exercise._id.toString(),
      ...exercise,
      levels: enrichedLevels
    }];
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
