import bcrypt from "bcrypt";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from "../config/jwtConfig.js";
import Parents from "../models/Parents.js";

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
        id: parent.id,
        name: parent.name,
        username: parent.username,
        email: parent.email,
        phoneNumber: parent.phoneNumber,
        nationality: parent.nationality,
        birthdate: parent.birthdate,
        accessToken,
        refreshToken,
    };
};

// Parent Registration
export const signUpParent = async ({ name, username, email, password, phoneNumber, nationality, birthdate,gender }) => {
    if (!name || !username || !password || !nationality || !birthdate || !gender) {
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

    const existingParent = await Parents.findOne({ $or: [{ username }, { email }] });
    if (existingParent) throw new Error("Username or Email already exists");

    const hashedPassword = await bcrypt.hash(password, 7);

    const newParent = new Parents({
        name,
        username,
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
    const accessToken = generateAccessToken({ id: newParent.id, username: newParent.username });
    const refreshToken = generateRefreshToken({ id: newParent.id, username: newParent.username });

    // Save refresh token
    newParent.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await newParent.save();

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

        // Remove old refresh token
        parent.refreshTokens = parent.refreshTokens.filter(rt => rt.token !== refreshToken);

        // Generate new tokens
        const newAccessToken = generateAccessToken({ id: parent.id, username: parent.username });
        const newRefreshToken = generateRefreshToken({ id: parent.id, username: parent.username });

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
