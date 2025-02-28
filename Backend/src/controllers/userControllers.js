import bcrypt from 'bcrypt';
import { generateAccessToken, generateRefreshToken } from '../config/jwtConfig.js';
import Users from '../models/Users.js';
import Parents from '../models/Parents.js';
import { sendWelcomeEmail } from '../config/emailConfig.js';
import { requestOTP, verifyOTP, resetPassword } from '../services/passwordResetService.js'
// Login function
export const login = async (username, password) => {
    if (!username || !password) {
        throw new Error('Username and password are required');
    }
    const user = await Users.findOne({ username });
    if (!user) throw new Error('User not found');

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) throw new Error('Invalid password');

    // Generate tokens
    const accessToken = generateAccessToken({ id: user.id, username: user.username });
    const refreshToken = generateRefreshToken({ id: user.id, username: user.username });

    // Remove expired refresh tokens before saving
    user.refreshTokens = user.refreshTokens.filter(rt => rt.expiresAt > new Date());

    // Save refresh token
    user.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await user.save();

    return {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        phoneNumber: user.phoneNumber,
        nationality: user.nationality,
        birthdate: user.birthdate,
        accessToken,
        refreshToken,
        role: user.role,
    };
};

// Refresh token function
export const refreshTokenUser = async (refreshToken) => {
    if (!refreshToken) {
        throw new Error('Refresh token is required');
    }

    const user = await Users.findOne({ 'refreshTokens.token': refreshToken });
    if (!user) {
        throw new Error('Invalid refresh token');
    }

    // Remove old refresh token
    user.refreshTokens = user.refreshTokens.filter(rt => rt.token !== refreshToken);

    // Generate new tokens
    const newAccessToken = generateAccessToken({ id: user.id, username: user.username });
    const newRefreshToken = generateRefreshToken({ id: user.id, username: user.username });

    // Save new refresh token
    user.refreshTokens.push({ token: newRefreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await user.save();

    return {
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        phoneNumber: user.phoneNumber,
        nationality: user.nationality,
        birthdate: user.birthdate,
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        role: user.role,
    };
};

// Logout function
export const logout = async (refreshToken) => {
    if (!refreshToken) {
        throw new Error("Refresh token required");
    }

    const user = await Users.findOne({ "refreshTokens.token": refreshToken });

    if (!user) {
        throw new Error("User not found or token invalid");
    }

    // Remove the specific refresh token from the array
    user.refreshTokens = user.refreshTokens.filter(rt => rt.token !== refreshToken);
    await user.save();

    return { message: "Logged out successfully" };
};

// Sign-up function for adults
export const signUpAdult = async ({ name, username, email, password, phoneNumber, nationality, birthdate, gender, role }) => {
    if (!name || !username || !password || !nationality || !birthdate || !gender || !role) {
        throw new Error('All required fields must be provided');
    }

    if (role !== 'adult') {
        throw new Error('Invalid role');
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
    const existingUser = await Users.findOne({ $or: [{ username }, { email }] });
    if (existingUser) throw new Error('Username or Email already exists');

    const hashedPassword = await bcrypt.hash(password, 7);

    const newUser = new Users({
        name,
        username,
        email,
        password: hashedPassword,
        phoneNumber,
        nationality,
        birthdate,
        gender,
        role,
        refreshTokens: [],
    });

    //await newUser.save();

    // Generate tokens
    const accessToken = generateAccessToken({ id: newUser.id, username: newUser.username });
    const refreshToken = generateRefreshToken({ id: newUser.id, username: newUser.username });

    // Save refresh token to the database
    newUser.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await newUser.save();
    await sendWelcomeEmail(newUser.email, newUser.name);
    return {
        id: newUser.id,
        name: newUser.name,
        username: newUser.username,
        email: newUser.email,
        phoneNumber: newUser.phoneNumber,
        nationality: newUser.nationality,
        birthdate: newUser.birthdate,
        gender: newUser.gender,
        accessToken,
        refreshToken,
        role: newUser.role,
    };
};

// Sign-up function for children
export const signUpChild = async ({ parentId, name, username, password, nationality, birthdate, gender, role }) => {
    if (!name || !username || !password || !nationality || !birthdate || !gender || !role || !parentId) {
        throw new Error('All required fields must be provided');
    }

    if (role !== 'child') {
        throw new Error('Invalid role');
    }
    // Validate password length
    if (password.length < 8) {
        throw new Error('Password must be at least 8 characters long');
    }
    const parent = await Parents.findById(parentId);
    if (!parent) {
        throw new Error('Parent not found');
    }

    const existingUser = await Users.findOne({ username });
    if (existingUser) throw new Error('Username already exists');

    const hashedPassword = await bcrypt.hash(password, 7);

    const newUser = new Users({
        name,
        username,
        password: hashedPassword,
        nationality,
        birthdate,
        gender,
        role,
        refreshTokens: [],
    });

    //await newUser.save();

    parent.linkedChildren.push(newUser._id);
    await parent.save();

    // Generate tokens
    const accessToken = generateAccessToken({ id: newUser.id, username: newUser.username });
    const refreshToken = generateRefreshToken({ id: newUser.id, username: newUser.username });

    // Save refresh token
    newUser.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await newUser.save();

    return {
        child: newUser,
        parentId: parentId,
        accessToken,
        refreshToken,
    };
};

export const forgotUserPassword = async (email) => {
    return await requestOTP(email, "user");
  };
  
  export const verifyUserOTP = async (email, otp) => {
    return await verifyOTP(email, otp, "user");
  };
  
  export const resetUserPassword = async (token, newPassword) => {
    return await resetPassword(token, newPassword, "user");
  };


