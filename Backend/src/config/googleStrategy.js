import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import Parents from '../models/Parents.js';
import { generateAccessToken, generateRefreshToken } from '../config/jwtConfig.js';

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_CALLBACK_URL,
}, async (accessToken, refreshToken, profile, done) => {
  try {
    // Check if the user already exists in your database
    let parent = await Parents.findOne({ googleId: profile.id });

    if (!parent) {
      // Create a new parent if they don't exist
      parent = await Parents.create({
        googleId: profile.id,
        email: profile.emails[0].value,
        name: profile.displayName,
      });
    }

    // Generate JWT tokens
    const jwtAccessToken = generateAccessToken({ id: parent._id, email: parent.email });
    const jwtRefreshToken = generateRefreshToken({ id: parent._id, email: parent.email });

    // Save the refresh token in the database
    parent.refreshTokens.push({ token: jwtRefreshToken, expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) });
    await parent.save();

    // Return the parent and tokens
    done(null, { parent, jwtAccessToken, jwtRefreshToken });
  } catch (err) {
    done(err, null);
  }
}));