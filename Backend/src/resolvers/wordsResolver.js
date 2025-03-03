import Words from "../models/Words.js"
export const wordsResolvers = {
    Query: {
      getWordForExercise: async (_, { level }) => {
        console.log("Fetching words for level:", level);
        const words = await Words.aggregate([
          { $match: { level } },
          { $sample: { size: 10 } }
        ]);
        console.log("Words found:", words);
        return words;
      },
    },
  };
  