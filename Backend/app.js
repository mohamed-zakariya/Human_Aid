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
import './src/config/googleStrategy.js'; 
const app = express();
app.use(express.json());
// Initialize Passport
app.use(passport.initialize());

// Google OAuth routes
app.use(googleAuthController);
app.use((req, res, next) => {
  if (req.path !== "/graphql") {
    authenticateJWT(req, res, next);
  } else {
    next();
  }
});
//  Apollo Plugin for Logging Response Time
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
  });
};

// Start the application
(async () => {
  await connectDB();
  await startServer();
})();



