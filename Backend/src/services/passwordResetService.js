import Users from '../models/Users.js';
import Parents from '../models/Parents.js';
import sendOTPEmail from "../config/emailConfig.js";
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
  return "OTP sent successfully.";
};

export const verifyOTP = async (email, otp, userType) => {
  const Model = userType === "parent" ? Parents : Users;
  const user = await Model.findOne({ email });
  if (!user || user.otp !== otp || user.otpExpires < new Date()) {
    throw new Error("Invalid or expired OTP.");
  }

  // Generate JWT token for password reset
  const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: "15m" });

  // Clear OTP after verification
  user.otp = null;
  user.otpExpires = null;
  await user.save();

  return token;
};

export const resetPassword = async (token, newPassword, userType) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const Model = userType === "parent" ? Parents : Users;
    const user = await Model.findOne({ email: decoded.email });
    if (!user) throw new Error(`${userType} not found`);

    user.password = await bcrypt.hash(newPassword, 7);
    await user.save();

    return "Password reset successfully.";
  } catch (error) {
    throw new Error("Invalid or expired token.");
  }
};
