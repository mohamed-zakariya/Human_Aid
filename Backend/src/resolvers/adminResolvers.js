import bcrypt from 'bcryptjs';
import Users from '../models/Users.js';
import Words from '../models/Words.js';
import { generateAccessToken, generateRefreshToken } from '../config/jwtConfig.js';
import cloudinary from '../config/cloudinary.js';
import { GraphQLUpload } from 'graphql-upload';
import Sentences from '../models/Sentences.js';
import Parents from '../models/Parents.js';
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
async createWord(_, { word, level, image }) {
  // image is an Upload scalar (GraphQLUpload)
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

  const newWord = new Words({
    word,
    level,
    imageUrl: cloudRes.secure_url,
  });

  await newWord.save();

  return newWord;
},

async updateWord(_, { id, word, level, image }) {
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
  }
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
  return await Users.find();
},
  }
};
