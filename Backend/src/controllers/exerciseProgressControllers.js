import Exercisesprogress from "../models/Exercisesprogress.js"


export const getExercisesprogress = async (userId) => {
    if (!userId) {
        throw new Error("Learner ID is required");
    }

    try {
        const exerciseProgress = await Exercisesprogress.findById((exercise) => exercise.user_id == userId);
        console.log("ssssss",userId);
        if (!exerciseProgress) {
            throw new Error("Exercise progress not found");
        }
        return exerciseProgress;
    } catch (error) {
        throw new Error(`Error fetching exercise progress: ${error.message}`);
    }
};
