//app.js
import express from 'express';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { typeDefs } from './src/schemas/typeDefs.js';
import { connectDB } from './src/config/dbConfig.js';
import { authenticateJWT,authorizeRole } from './src/middleware/authMiddleware.js';
import { resolvers } from './src/resolvers/combineResolvers.js';
import { convertToWav } from './src/services/audioConvertor.js';
import { azureTranscribeAudio } from './src/config/azureapiConfig.js';
import googleAuthController from './src/controllers/googleAuthController.js';
import passport from 'passport';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { graphqlUploadExpress } from 'graphql-upload';
import './src/config/googleStrategy.js';
import cors from 'cors';


const app = express();



app.use(cors({
  origin: [
    'http://localhost:4200',
    'https://mohamed-zakariya.github.io',
  ],
  credentials: true,
}));



app.use(express.json());
// Serve uploaded files
app.use('/uploads', express.static('uploads'));

// Initialize Passport
app.use(passport.initialize());

// Google OAuth routes
app.use(googleAuthController);

app.use(
  '/graphql',
  graphqlUploadExpress({ maxFileSize: 10000000, maxFiles: 1 }) // Optional config
);

app.use((req, res, next) => {
  if (req.path !== "/graphql" && req.path !== "/upload-audio" && req.path !== "/api/transcribe") {
    authenticateJWT(req, res, next);
  } else {
    next();
  }  
});


// app.use(async (req, res, next) => {
//   if (
//     (req.path === "/graphql" && req.body?.query) ||
//     (req.path === "/auth/google" && req.method === "POST")
//   ) {
//     if (req.path === "/graphql") {
//       const { query } = req.body;
//       const operationMatch = query.match(/\bmutation\s+(\w+)/);
//       const operationName = operationMatch ? operationMatch[1] : null;

//       const publicOperations = [
//         "loginParent", "signUpParent", "refreshTokenParent",
//         "refreshTokenUser", "loginUser", "signUpChild",
//         "signUpAdult", "checkUserUsernameExists",
//          "checkParentEmailExists", "checkUserEmailExists"
//       ];

//       if (operationName && publicOperations.includes(operationName)) {
//         return next(); // Skip authentication for these GraphQL operations
//       }
//     }

//     if (req.path === "/auth/google" && req.method === "POST") {
//       return next(); // Skip authentication for Google sign-in route
//     }
//   }

//   authenticateJWT(req, res, next);
// });



// app.use(authenticateJWT)

// Set up Multer for file uploads (Audio)
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } });

app.post('/upload-audio', upload.single('audio'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file uploaded" });

  const inputPath = req.file.path;
  const ext = path.extname(inputPath).toLowerCase();
  let outputFilename = req.file.filename;
  
  // If already WAV, skip conversion
  if (ext !== '.wav') {
    outputFilename = `${Date.now()}-${path.basename(req.file.filename, ext)}.wav`;
    const outputPath = path.join('uploads', outputFilename);
    await convertToWav(inputPath, outputPath);
    // Optionally delete original if you don't need it
    fs.unlinkSync(inputPath);
  }

  const fileUrl = `http://localhost:5500/uploads/${outputFilename}`;
  console.log("Processed audio file:", fileUrl);
  res.json({ message: "Audio uploaded and processed", fileUrl });
});

app.post('/api/transcribe', async (req, res) => {
  const { filePath } = req.body;
  if (!filePath) return res.status(400).json({ error: 'filePath is required' });

  try {
    // Convert from URL to local path
    const filename = path.basename(filePath); // extract filename from URL
    const localPath = path.join('uploads', filename); // build local path

    const transcript = await azureTranscribeAudio(localPath); // use local path
    res.json({ transcript });
  } catch (err) {
    console.error('Transcription Error:', err.message);
    res.status(500).json({ error: 'Azure Transcription Failed' });
  }
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
