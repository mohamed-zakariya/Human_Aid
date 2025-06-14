import bcrypt from "bcrypt";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from "../config/jwtConfig.js";
import Parents from "../models/Parents.js";
import Exercises from "../models/Exercises.js";
import { sendWelcomeEmail } from '../config/emailConfig.js';
import { sendParentWelcomeEmail } from '../config/emailConfig.js';
import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
import { requestOTP, verifyOTP, resetPassword } from '../services/passwordResetService.js'
import mongoose from "mongoose";

// Parent Login
export const loginParent = async (email, password) => {
    if (!email || !password) {
        throw new Error('Email and password are required');
    }
    const parent = await Parents.findOne({ email });
    if (!parent) throw new Error("Parent not found");

    const isValid = await bcrypt.compare(password, parent.password);
    if (!isValid) throw new Error("Invalid password");

    // Generate tokens
    const accessToken = generateAccessToken({ id: parent.id, email: parent.email });
    const refreshToken = generateRefreshToken({ id: parent.id, email: parent.email });

    // Remove expired refresh tokens
    parent.refreshTokens = parent.refreshTokens.filter(rt => rt.expiresAt > new Date());

    // Save new refresh token
    parent.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await parent.save();


    return {
        parent,
        accessToken,
        refreshToken,
    };
};

// get parent data by id
export const getParentDataById = async (parentId) => {
    if (!parentId) {
        throw new Error('Parent ID is required');
    }

    const parent = await Parents.findById(parentId).select('-password -refreshTokens'); // Exclude sensitive fields
    if (!parent) {
        throw new Error('Parent not found');
    }

    return parent;
};




// Parent Registration
export const signUpParent = async ({ name,email, password, phoneNumber, nationality, birthdate,gender }) => {
    if (!name || !email || !password || !nationality || !birthdate || !gender) {
        throw new Error("All required fields must be provided");
    }
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        throw new Error('Invalid email format');
    }

    // Validate password length
    if (password.length < 8) {
        throw new Error('Password must be at least 8 characters long');
    }
    const existingParent = await Parents.findOne({ email });
    if (existingParent) throw new Error(" Email already exists");

    const hashedPassword = await bcrypt.hash(password, 7);

    const newParent = new Parents({
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        nationality,
        birthdate,
        gender,
        refreshTokens: [],
    });

    //await newParent.save();

    // Generate tokens
    const accessToken = generateAccessToken({ id: newParent.id, email: newParent.email });
    const refreshToken = generateRefreshToken({ id: newParent.id, email: newParent.email });

    // Save refresh token
    newParent.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await newParent.save();
    await sendParentWelcomeEmail(newParent.email, newParent.name);
    return {
        parent: newParent,
        accessToken,
        refreshToken,
    };
};

// Refresh Token
export const refreshTokenParent = async (refreshToken) => {
    if (!refreshToken) {
        throw new Error("Refresh token is required");
    }

    try {
        const decoded = verifyRefreshToken(refreshToken);
        const parent = await Parents.findOne({ "refreshTokens.token": refreshToken });

        if (!parent) {
            throw new Error("Invalid refresh token");
        }
        // Generate new tokens
        const newAccessToken = generateAccessToken({ id: parent.id, username: parent.username });
        const newRefreshToken = generateRefreshToken({ id: parent.id, username: parent.username });
        // Remove old refresh token
        parent.refreshTokens = parent.refreshTokens.filter(rt => rt.token !== refreshToken);
        // Save new refresh token
        parent.refreshTokens.push({ token: newRefreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
        await parent.save();

        return { accessToken: newAccessToken, refreshToken: newRefreshToken };
    } catch (error) {
        throw new Error("Invalid or expired refresh token");
    }
};

// Parent Logout
export const logout = async (refreshToken) => {
    if (!refreshToken) {
        throw new Error("Refresh token required");
    }

    const parent = await Parents.findOne({ "refreshTokens.token": refreshToken });

    if (!parent) {
        throw new Error("User not found or token invalid");
    }

    // Remove the specific refresh token from the array
    parent.refreshTokens = parent.refreshTokens.filter(rt => rt.token !== refreshToken);
    await parent.save();

    return { message: "Logged out successfully" };
};

export const forgotParentPassword = async (email) => {
    return await requestOTP(email, "parent");
  };
  
export const verifyParentOTP = async (email, otp) => {
    // returns { token } only
    return await verifyOTP(email, otp, "parent");
  };
  
  
  
export const resetParentPassword = async (token, newPassword) => {
return await resetPassword(token, newPassword, "parent");
};

export const getLearnerProgress = async (parentId) => {
  try {
    const result = await Parents.aggregate([
      {
        $match: { _id: new mongoose.Types.ObjectId(parentId) }
      },
      {
        $lookup: {
          from: "exercisesprogresses",
          localField: "linkedChildren",
          foreignField: "user_id",
          as: "progress"
        }
      },
      {
        $project: {
          id: "$_id",
          progress: {
            user_id: 1,
            exercise_id: 1,
            total_time_spent: 1,
            levels: {
              level_id: 1,
              correct_items: 1,
              incorrect_items: 1,
              games: {
                game_id: 1,
                scores: 1
              }
            }
          }
        }
      }
    ]);

    if (!result.length) throw new Error("Parent not found");

    return result[0]; // Return parent with children’s progress data
  } catch (error) {
    console.error("Error fetching learner progress:", error);
    throw new Error(`Error fetching learner progress: ${error.message}`);
  }
};

export const getLearnerOverallProgress = async (parentId) => {
    try {
        const result = await Parents.aggregate([
            {
                $match: { _id: new mongoose.Types.ObjectId(parentId) }
            },
            {
                $lookup: {
                    from: "overallprogresses",
                    localField: "linkedChildren",
                    foreignField: "user_id",
                    as: "progress"
                }
            },
            {
                $unwind: "$progress"
            },
            {
                $lookup: {
                    from: "users",
                    localField: "progress.user_id",
                    foreignField: "_id",
                    as: "userData"
                }
            },
            {
                $unwind: "$userData"
            },
            {
                $group: {
                    _id: "$_id",
                    progress: {
                        $push: {
                            user_id: "$progress.user_id",
                            name: "$userData.name",
                            username: "$userData.username",
                            progress_by_exercise: "$progress.progress_by_exercise",
                            overall_stats: "$progress.overall_stats"
                        }
                    }
                }
            },
            {
                $project: {
                    id: "$_id",
                    progress: 1
                }
            }
        ]);

        if (!result.length) throw new Error("Parent not found");
        return result[0];
    } catch (error) {
        console.error("Error fetching learner overall progress:", error);
        throw new Error(`Error fetching learner overall progress: ${error.message}`);
    }
};
export const getLearnerDailyAttempts = async (parentId, days = 7) => {
  try {
    const parent = await Parents.findById(parentId).lean();
    if (!parent) throw new Error("Parent not found");

    const childIds = parent.linkedChildren;
    if (!childIds.length) throw new Error("No linked children found");

    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999);

    const startDate = new Date();
    startDate.setDate(endDate.getDate() - (days - 1));
    startDate.setHours(0, 0, 0, 0);

    const result = await DailyAttemptTracking.aggregate([
      {
        $match: {
          user_id: { $in: childIds.map(id => new mongoose.Types.ObjectId(id)) },
          date: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $lookup: {
          from: "users",
          localField: "user_id",
          foreignField: "_id",
          as: "user"
        }
      },
      { $unwind: "$user" },
      {
        $group: {
          _id: "$date",
          users: {
            $push: {
              user_id: "$user._id",
              name: { $ifNull: ["$user.name", ""] },
              username: { $ifNull: ["$user.username", ""] },

              correct_words: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$words_attempts", []] },
                      as: "wa",
                      cond: { $eq: ["$$wa.is_correct", true] }
                    }
                  },
                  as: "cw",
                  in: {
                    word_id: "$$cw.word_id",
                    correct_word: "$$cw.correct_word",
                    spoken_word: "$$cw.spoken_word"
                  }
                }
              },
              incorrect_words: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$words_attempts", []] },
                      as: "wa",
                      cond: { $eq: ["$$wa.is_correct", false] }
                    }
                  },
                  as: "iw",
                  in: {
                    word_id: "$$iw.word_id",
                    correct_word: "$$iw.correct_word",
                    spoken_word: "$$iw.spoken_word"
                  }
                }
              },

              correct_letters: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$letters_attempts", []] },
                      as: "la",
                      cond: { $eq: ["$$la.is_correct", true] }
                    }
                  },
                  as: "cl",
                  in: {
                    letter_id: "$$cl.letter_id",
                    correct_letter: "$$cl.correct_letter",
                    spoken_letter: "$$cl.spoken_letter"
                  }
                }
              },
              incorrect_letters: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$letters_attempts", []] },
                      as: "la",
                      cond: { $eq: ["$$la.is_correct", false] }
                    }
                  },
                  as: "il",
                  in: {
                    letter_id: "$$il.letter_id",
                    correct_letter: "$$il.correct_letter",
                    spoken_letter: "$$il.spoken_letter"
                  }
                }
              },

              correct_sentences: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$sentences_attempts", []] },
                      as: "sa",
                      cond: { $eq: ["$$sa.is_correct", true] }
                    }
                  },
                  as: "cs",
                  in: {
                    sentence_id: "$$cs.sentence_id",
                    correct_sentence: "$$cs.correct_sentence",
                    spoken_sentence: "$$cs.spoken_sentence"
                  }
                }
              },
              incorrect_sentences: {
                $map: {
                  input: {
                    $filter: {
                      input: { $ifNull: ["$sentences_attempts", []] },
                      as: "sa",
                      cond: { $eq: ["$$sa.is_correct", false] }
                    }
                  },
                  as: "is",
                  in: {
                    sentence_id: "$$is.sentence_id",
                    correct_sentence: "$$is.correct_sentence",
                    spoken_sentence: "$$is.spoken_sentence"
                  }
                }
              },

              game_attempts: {
                $map: {
                  input: { $ifNull: ["$game_attempts", []] },
                  as: "ga",
                  in: {
                    game_id: "$$ga.game_id",
                    level_id: "$$ga.level_id",
                    attempts: "$$ga.attempts"
                  }
                }
              }
            }
          }
        }
      },
      {
        $project: {
          _id: 0,
          date: { $dateToString: { format: "%Y-%m-%d", date: "$_id" } },
          users: 1
        }
      },
      { $sort: { date: 1 } }
    ]);

    // Load all exercises with levels and games
    const exercises = await Exercises.find({}, { levels: 1 }).lean();
// Build lookup maps for level and game names including arabic_name
const gameIdToData = {};
const levelIdToData = {};

for (const exercise of exercises) {
  for (const level of exercise.levels) {
    const levelIdStr = level._id?.toString();
    if (levelIdStr) {
      levelIdToData[levelIdStr] = {
        name: level.name,
        arabic_name: level.arabic_name,
      };
    }

    for (const game of level.games) {
      const gameIdStr = game._id?.toString();
      if (gameIdStr) {
        gameIdToData[gameIdStr] = {
          name: game.name,
          arabic_name: game.arabic_name,
        };
      }
    }
  }
}

for (const day of result) {
  for (const user of day.users) {
    if (!user.game_attempts) continue;

    user.game_attempts = user.game_attempts.map(attempt => {
      const gameData = gameIdToData[attempt.game_id?.toString()] || {};
      const levelData = levelIdToData[attempt.level_id?.toString()] || {};

      return {
        ...attempt,
        game_name: gameData.name || null,
        game_arabic_name: gameData.arabic_name || null,
        level_name: levelData.name || null,
        level_arabic_name: levelData.arabic_name || null,
      };
    });
  }
}

return result;

  } catch (error) {
    console.error("Error fetching learner daily attempts:", error);
    throw new Error(`Error fetching learner daily attempts: ${error.message}`);
  }
};
