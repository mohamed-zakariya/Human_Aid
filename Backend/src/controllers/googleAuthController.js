import express from 'express';
import jwt from 'jsonwebtoken';
import Parents from '../models/Parents.js';
import { generateAccessToken, generateRefreshToken } from '../config/jwtConfig.js';
import { OAuth2Client } from 'google-auth-library';

const router = express.Router();
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// ✅ New route for Google Sign-In from Flutter
router.post('/auth/google', async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ error: 'ID Token is required' });
    }

    // Verify Google token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const googleId = payload.sub;
    const email = payload.email;
    const name = payload.name;

    // Check if parent exists
    let parent = await Parents.findOne({ googleId });

    if (!parent) {
      // Create a new parent if not found
      parent = await Parents.create({
        googleId,
        email,
        name,
      });
    }

    // Generate JWT tokens
    const accessToken = generateAccessToken({ id: parent._id, email: parent.email });
    const refreshToken = generateRefreshToken({ id: parent._id, email: parent.email });

    // Save refresh token
    parent.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await parent.save();

    res.json({
      parent,
      accessToken,
      refreshToken,
    });

  } catch (error) {
    console.error("Google Auth Error:", error);
    res.status(500).json({ error: 'Authentication failed' });
  }
});

export default router;
