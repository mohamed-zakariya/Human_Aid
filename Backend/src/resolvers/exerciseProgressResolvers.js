import { Query } from "mongoose";
import Exercisesprogress from "../models/Exercisesprogress.js"


export const exerciseProgressResolvers = {
    Query: {
        getExercisesprogress: async (_, { userId }) => {
            console.log("Fetching exercise progress for user:", userId);
        
            if (!userId) {
                throw new Error("User ID is required");
            }
        
            try {
                const exerciseProgress = await Exercisesprogress.findOne({ user_id: userId });
        
                if (!exerciseProgress) {
                    throw new Error("Exercise progress not found");
                }
        
                return exerciseProgress;
            } catch (error) {
                console.error("Error fetching exercise progress:", error);
                throw new Error(`Error fetching exercise progress: ${error.message}`);
            }
        }
    }
}