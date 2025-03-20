import bcrypt from "bcrypt";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from "../config/jwtConfig.js";
import Parents from "../models/Parents.js";
import { sendWelcomeEmail } from '../config/emailConfig.js';
import UserDailyAttempts from "../models/UserDailyAttempts.js";
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
    await sendWelcomeEmail(newParent.email, newParent.name);
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
                $match: { _id: new mongoose.Types.ObjectId(parentId) } // Ensure parentId is an ObjectId
            },
            {
                $lookup: {
                    from: "exercisesprogresses", // Collection name should be lowercase and plural
                    localField: "linkedChildren",
                    foreignField: "user_id",
                    as: "progress"
                }
            },
            {
                $project: {
                    id: "$_id",
                    progress: {
                        user_id: 1, // Child ID
                        exercise_id: 1, // Exercise ID
                        correct_words: 1, // Correct words
                        incorrect_words: 1, // Incorrect words
                        accuracy_percentage: 1, // Accuracy score
                        score: 1, // Total score
                        exercise_time_spent: 1 // Time spent on exercise
                    }
                }
            }
        ]);

        if (!result.length) throw new Error("Parent not found");

        return result[0]; // Return the parent with linked progress
    } catch (error) {
        console.error("Error fetching learner progress:", error);
        throw new Error(`Error fetching learner progress: ${error.message}`);
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

        const result = await UserDailyAttempts.aggregate([
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
                            name: "$user.name",
                            username: "$user.username",
                            correct_words: {
                                $map: {
                                    input: {
                                        $filter: {
                                            input: "$attempts",
                                            as: "attempt",
                                            cond: { $eq: ["$$attempt.is_correct", true] }
                                        }
                                    },
                                    as: "cw",
                                    in: {
                                        word_id: { $ifNull: ["$$cw.word_id", "UNKNOWN"] },
                                        correct_word: "$$cw.correct_word",
                                        spoken_word: "$$cw.spoken_word"
                                    }
                                }
                            },
                            incorrect_words: {
                                $map: {
                                    input: {
                                        $filter: {
                                            input: "$attempts",
                                            as: "attempt",
                                            cond: { $eq: ["$$attempt.is_correct", false] }
                                        }
                                    },
                                    as: "iw",
                                    in: {
                                        word_id: { $ifNull: ["$$iw.word_id", "UNKNOWN"] },
                                        correct_word: "$$iw.correct_word",
                                        spoken_word: "$$iw.spoken_word"
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

        return result;
    } catch (error) {
        console.error("Error fetching learner daily attempts:", error);
        throw new Error(`Error fetching learner daily attempts: ${error.message}`);
    }
};




