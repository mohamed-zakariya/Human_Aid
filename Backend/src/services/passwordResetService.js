import Users from '../models/Users.js';
import Parents from '../models/Parents.js';
import {sendOTPEmail} from "../config/emailConfig.js";
import bcrypt from 'bcrypt';
import jwt from "jsonwebtoken";

// Generate OTP
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

export const requestOTP = async (email, userType) => {
  const Model = userType === "parent" ? Parents : Users;
  const user = await Model.findOne({ email });
  if (!user) throw new Error(`${userType} not found`);

  const otp = generateOTP();
  const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes validity

  user.otp = otp;
  user.otpExpires = otpExpires;
  await user.save();

  await sendOTPEmail(email, otp);
  return { message: "OTP sent successfully" };
};

export const verifyOTP = async (email, otp, userType) => {
  console.log("Verifying OTP for:", email, otp, userType);

  const Model = userType === "parent" ? Parents : Users;
  const user = await Model.findOne({ email });
  console.log("User found:", user);

  if (!user) {
    console.log("User not found.");
    throw new Error("User not found.");
  }

  if (user.otp !== otp) {
    console.log("Invalid OTP.");
    throw new Error("Invalid OTP.");
  }

  if (user.otpExpires < new Date()) {
    console.log("OTP has expired.");
    throw new Error("OTP has expired.");
  }

  if (!process.env.JWT_SECRET) {
    console.log("JWT secret is not configured.");
    throw new Error("JWT secret is not configured.");
  }

  const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: "15m" });
  console.log("Token generated:", token);

  user.otp = null;
  user.otpExpires = null;
  await user.save();

  return {
    message: "OTP verified successfully",
    token,
  };
};

export const resetPassword = async (token, newPassword, userType) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const Model = userType === "parent" ? Parents : Users;
    const user = await Model.findOne({ email: decoded.email });
    if (!user) throw new Error(`${userType} not found`);

    user.password = await bcrypt.hash(newPassword, 7);
    await user.save();
    return { message: "Password reset successfully." }
  } catch (error) {
    throw new Error("Invalid or expired token.");
  }
};
