import express from 'express';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { typeDefs } from './src/schemas/typeDefs.js';
import { connectDB } from './src/config/dbConfig.js';
import { authenticateJWT } from './src/middleware/authMiddleware.js';
import { resolvers } from './src/resolvers/combineResolvers.js';
import { makeExecutableSchema } from "@graphql-tools/schema";
import googleAuthController from './src/controllers/googleAuthController.js';
import passport from 'passport';
import multer from 'multer';
import path from 'path';
import './src/config/googleStrategy.js';

const app = express();
app.use(express.json());
// Serve uploaded files
app.use('/uploads', express.static('uploads'));



// Initialize Passport
app.use(passport.initialize());

// Google OAuth routes
app.use(googleAuthController);

// app.use((req, res, next) => {
//   if (req.path !== "/graphql" && req.path !== "/upload-audio") {
//     authenticateJWT(req, res, next);
//   } else {
//     next();
//   }  
// });
app.use(async (req, res, next) => {
  if (req.path === "/graphql" && req.body?.query) {
    const { query } = req.body;

    // Extract operation name from the query string
    const operationMatch = query.match(/\bmutation\s+(\w+)/);
    const operationName = operationMatch ? operationMatch[1] : null;

    const publicOperations = ["loginParent",
       "signUpParent", "refreshTokenParent",
         "loginUser", "signUpChild",
          "signUpAdult", "googleLogin",
           "checkUserUsernameExists", "checkParentEmailExists",
            "checkUserEmailExists"];

    if (operationName && publicOperations.includes(operationName)) {
      return next(); // Allow unauthenticated access
    }
  }

  authenticateJWT(req, res, next);
});


// app.use(authenticateJWT)

// Set up Multer for file uploads (Audio)
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } });

// Speech Upload Route
app.post('/upload-audio', upload.single('audio'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }

  // Return public URL instead of file path
  const fileUrl = `http://localhost:5500/uploads/${req.file.filename}`;
  console.log("Received audio file:", fileUrl);
  res.json({ message: "Audio received", fileUrl });
});

// Apollo Plugin for Logging Response Time
const responseTimePlugin = {
  requestDidStart() {
    const startTime = Date.now();
    return {
      willSendResponse(requestContext) {
        const endTime = Date.now();
        const duration = endTime - startTime;
        console.log(`API [${requestContext.request.operationName || "Unnamed Query"}] took ${duration}ms`);
      },
    };
  },
};

// Initialize Apollo Server
const startServer = async () => {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [responseTimePlugin],
  });

  await server.start();

  // Apply Apollo Server middleware
  app.use('/graphql', expressMiddleware(server, {
    context: async ({ req }) => ({ user: req.user }), // Pass user info to resolvers
  }));

  // Start the server
  const PORT = process.env.PORT || 5500;
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`GraphQL endpoint available at http://localhost:${PORT}/graphql`);
    console.log(`Upload endpoint: http://localhost:${PORT}/upload-audio`);
  });
};

// Start the application
(async () => {
  await connectDB();
  await startServer();
})();
