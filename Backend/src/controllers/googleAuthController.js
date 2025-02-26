import express from 'express';
import passport from 'passport';

const router = express.Router();

// Redirect to Google for authentication
router.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

// Google callback
router.get('/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/login', session: false }),
  (req, res) => {
    // Return JWT tokens to the client
    const { jwtAccessToken, jwtRefreshToken } = req.user;
    res.json({ accessToken: jwtAccessToken, refreshToken: jwtRefreshToken });
  }
);

export default router;