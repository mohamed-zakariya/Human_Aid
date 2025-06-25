import bcrypt from 'bcryptjs';
import Users from '../models/Users.js';
import Words from '../models/Words.js';
import { generateAccessToken, generateRefreshToken } from '../config/jwtConfig.js';
import cloudinary from '../config/cloudinary.js';
import { GraphQLUpload } from 'graphql-upload';
import Sentences from '../models/Sentences.js';
import Parents from '../models/Parents.js';
import Stories from "../models/Stories.js";
import { sendInactivityEmail } from "../config/emailConfig.js";
import dayjs from "dayjs";
import mongoose from 'mongoose';
import Exercisesprogress from '../models/Exercisesprogress.js';



export const adminResolvers = {
  Upload: GraphQLUpload,
  Mutation: {
    async loginAdmin(_, { username, password }) {
      const admin = await Users.findOne({ username, role: "admin" });
      if (!admin) throw new Error("Admin not found");

      const valid = await bcrypt.compare(password, admin.password);
      if (!valid) throw new Error("Invalid password");

      const accessToken = generateAccessToken({ id: admin._id, role: admin.role });
      const refreshToken = generateRefreshToken({ id: admin._id, role: admin.role });

      admin.refreshTokens.push({ token: refreshToken, expiresAt: new Date(Date.now() + 30 * 86400000) });
      await admin.save();

      return { accessToken, refreshToken, user: admin };
    },

    // CREATE a word
async createWord(_, { word, level, image ,synonym}) {
  try {
    let imageUrl = null;

    if (image) {
      const { createReadStream } = await image;
      const stream = createReadStream();

      const cloudRes = await new Promise((resolve, reject) => {
        const streamUpload = cloudinary.uploader.upload_stream(
          { folder: 'words' },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        );
        stream.pipe(streamUpload);
      });

      imageUrl = cloudRes.secure_url;
    }

    const newWord = new Words({ word, level, imageUrl,synonym });
    await newWord.save();

    return newWord;
  } catch (err) {
    throw new Error('Failed to create word: ' + err.message);
  }
},

async updateWord(_, { id, word, level, image,synonym }) {
  let imageUrl;

  if (image) {
    const { createReadStream } = await image;
    const stream = createReadStream();

    const cloudRes = await new Promise((resolve, reject) => {
      const streamUpload = cloudinary.uploader.upload_stream(
        { folder: 'words' },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.pipe(streamUpload);
    });

    imageUrl = cloudRes.secure_url;
  }

  const updatedWord = await Words.findByIdAndUpdate(
    id,
    {
      ...(word !== undefined && { word }),
      ...(level !== undefined && { level }),
      ...(imageUrl !== undefined && { imageUrl }),
      ...(synonym !== undefined && { synonym }),
    },
    { new: true }
  );

  if (!updatedWord) throw new Error('Word not found');
  return updatedWord;
},

    // DELETE a word by ID
    async deleteWord(_, { id }) {
      const deletedWord = await Words.findByIdAndDelete(id);
      if (!deletedWord) throw new Error('Word not found');
      return deletedWord;
    },
      async createSentence(_, { sentence, level }) {
      const newSentence = new Sentences({ sentence, level });
      await newSentence.save();
      return newSentence;
    },

    // UPDATE a sentence by ID
    async updateSentence(_, { id, sentence, level }) {
      const updatedSentence = await Sentences.findByIdAndUpdate(
        id,
        {
          ...(sentence !== undefined && { sentence }),
          ...(level !== undefined && { level }),
        },
        { new: true }
      );
      if (!updatedSentence) throw new Error('Sentence not found');
      return updatedSentence;
    },

    // DELETE a sentence by ID
    async deleteSentence(_, { id }) {
      const deletedSentence = await Sentences.findByIdAndDelete(id);
      if (!deletedSentence) throw new Error('Sentence not found');
      return deletedSentence;
    },
    async deleteParentAndChildren(_, { parentId }) {
    const parent = await Parents.findById(parentId);
    if (!parent) throw new Error('Parent not found');
    // Delete all linked children
    await Users.deleteMany({ _id: { $in: parent.linkedChildren } });
    // Delete the parent
    await Parents.findByIdAndDelete(parentId);
    return true;
  },
    async deleteUser(_, { userId }) {
    const learner = await Users.findById(userId);
    if (!learner) throw new Error('Learner not found');
    // If the learner is a child, delete the parent-child link
    if (learner.role === 'child') {
      await Parents.updateMany(
        { linkedChildren: userId },
        { $pull: { linkedChildren: userId } }
      );
    }
    // Delete the learner
    await Users.findByIdAndDelete(userId);
    return true;
  },
      createStory: async (_, { story, kind, summary, morale }) => {
      const newStory = new Stories({ story, kind, summary, morale });
      await newStory.save();
      return newStory;
    },
    updateStory: async (_, { id, story, kind, summary, morale }) => {
      const updatedStory = await Stories.findByIdAndUpdate(
        id,
        { story, kind, summary, morale },
        { new: true }
      );
      if (!updatedStory) throw new Error("Story not found");
      return updatedStory;
    },
    deleteStory: async (_, { id }) => {
      const deletedStory = await Stories.findByIdAndDelete(id);
      if (!deletedStory) throw new Error("Story not found");
      return deletedStory;
    },
    sendInactivityEmailToUser: async (_, { userId, parentId }) => {
  const user = await Users.findById(userId);
  if (!user) throw new Error("User not found");

  if (!user.lastActiveDate) throw new Error("No last_active_date found for user");

  if (user.role === 'adult') {
    await sendInactivityEmail(user.email, "adult", user.username, user.lastActiveDate);
    return { success: true, message: "Email sent to adult learner." };
  }

  if (user.role === 'child') {
    if (!parentId) throw new Error("Parent ID required for child users");

    const parent = await Parents.findById(parentId);
    if (!parent) throw new Error("Parent not found");

    await sendInactivityEmail(parent.email, "parent", parent.name, user.lastActiveDate, user.username);
    return { success: true, message: "Email sent to parent about child's inactivity." };
  }

  throw new Error("Invalid user role");
},
  },

  Query: {
    // Get all words
    async getWords() {
      return await Words.find();
    },

    // Get single word by ID
    async getWord(_, { id }) {
      const word = await Words.findById(id);
      if (!word) throw new Error('Word not found');
      return word;
    },
    async getSentences() {
      return await Sentences.find();
    },

    // Get single sentence by ID
    async getSentence(_, { id }) {
      const sentence = await Sentences.findById(id);
      if (!sentence) throw new Error('Sentence not found');
      return sentence;
    },
    async getUserStats() {
      const numAdults = await Users.countDocuments({ role: 'adult' });
      const numChildren = await Users.countDocuments({ role: 'child' });
      const numParents = await Parents.countDocuments();
      return { numAdults, numChildren, numParents };
    },

    async getAllParentsWithChildren() {
    // Populate linkedChildren with full user details
    return await Parents.find().populate('linkedChildren');
  },
  async getAllUsers() {
    // Fetch all users
    const users = await Users.find({ role: { $in: ['adult', 'child'] } }).lean();

    // Fetch parent-child mappings
    const parents = await Parents.find({}, { _id: 1, linkedChildren: 1 }).lean();

    // Create a map of childId → parentId
    const childToParentMap = new Map();
    for (const parent of parents) {
      for (const childId of parent.linkedChildren || []) {
        childToParentMap.set(childId.toString(), parent._id.toString());
      }
    }

  return users.map(user => {
    const { _id, ...rest } = user; // 🔥 remove _id from the rest
    return {
      id: _id.toString(),         // ✅ GraphQL expects 'id'
      ...rest,
      parentId: user.role === 'child' ? childToParentMap.get(_id.toString()) || null : null
    };
  });


  },
  
  getStories: async () => {
      return await Stories.find();
    },
  getStory: async (_, { id }) => {
    const story = await Stories.findById(id);
    if (!story) throw new Error("Story not found");
    return story;
  },

  getStoryByProgress: async (_, { learnerId }) => {
    const STORY_EXERCISE_ID = new mongoose.Types.ObjectId("6846f1396da181555b92c7c2");
    const STORY_COMPREHENSION_GAME_ID = new mongoose.Types.ObjectId("684a222f9b4f0e13211a270d");

    // Aggregate to count how many scores > 8 for the specific game
    const result = await Exercisesprogress.aggregate([
      {
        $match: {
          user_id: new mongoose.Types.ObjectId(learnerId),
          exercise_id: STORY_EXERCISE_ID,
        }
      },
      { $unwind: "$levels" },
      { $unwind: "$levels.games" },
      {
        $match: {
          "levels.games.game_id": STORY_COMPREHENSION_GAME_ID,
        }
      },
      {
        $project: {
          scoresAbove8: {
            $size: {
              $filter: {
                input: "$levels.games.scores",
                as: "score",
                cond: { $gt: ["$$score", 8] }
              }
            }
          }
        }
      },
      {
        $group: {
          _id: null,
          totalAttempts: { $sum: "$scoresAbove8" }
        }
      }
    ]);

    const attempts = result[0]?.totalAttempts || 0;

    // Determine the story kind
    let kind = "قصة قصيرة";
    if (attempts >= 6) kind = "قصة طويلة";
    else if (attempts >= 3) kind = "قصة متوسطة";

    // Get 3 random stories of that kind
    const stories = await Stories.aggregate([
      { $match: { kind } },
      { $sample: { size: 3 } }
    ]);

    return stories.map(story => ({
      id: story._id.toString(),
      story: story.story,
      kind: story.kind,
      summary: story.summary,
      morale: story.morale
    }));
  }

  },
};
