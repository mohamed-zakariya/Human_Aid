import DailyAttemptTracking from "../models/DailyAttemptTracking.js";
import Exercisesprogress from "../models/Exercisesprogress.js";
import OverallProgress from "../models/OverallProgress.js";
import mongoose from "mongoose";

async function UserDailyGamesAttempts(userId, levelId, gameId, score,session) {
  const startOfDay = new Date(); startOfDay.setUTCHours(0, 0, 0, 0);
  const endOfDay = new Date(); endOfDay.setUTCHours(23, 59, 59, 999);

  let userAttempt = await DailyAttemptTracking.findOne({
    user_id: userId,
    date: { $gte: startOfDay, $lte: endOfDay },
  }).session(session);

  if (!userAttempt) {
    userAttempt = new DailyAttemptTracking({
      user_id: userId,
      date: new Date(),
      game_attempts: []
    });
  }

  const gameEntry = userAttempt.game_attempts.find(
  entry => entry.game_id.toString() === gameId.toString() &&
           entry.level_id.toString() === levelId.toString()
);


  if (gameEntry) {
    gameEntry.attempts.push({ score });
  } else {
    userAttempt.game_attempts.push({
        game_id: gameId,
        level_id: levelId,
        attempts: [{ score }]
    });
  }

  await userAttempt.save({ session });
  return userAttempt;
}

async function updateExerciseProgress(userId, exerciseId, levelId, gameId, score, session) {
    let progress = await Exercisesprogress.findOne({ user_id: userId, exercise_id: exerciseId }).session(session);

    if (!progress) {
      progress = new Exercisesprogress({
        user_id: userId,
        exercise_id: exerciseId,
        total_time_spent: 0,
        session_start: new Date(),
        levels: [{
          level_id: levelId,  
          correct_items: [],
          incorrect_items: [],
          games: [{ game_id: gameId, scores: [score] }]
        }]
      });
    } else {
      let level = progress.levels.find(l => l.level_id.equals(levelId));  
      
      if (!level) {
        progress.levels.push({
          level_id: levelId,
          correct_items: [],
          incorrect_items: [],
          games: [{ game_id: gameId, scores: [score] }]
        });
      } else {
        let game = level.games.find(g => g.game_id.equals(gameId));
        if (game) {
          game.scores.push(score);
        } else {
          level.games.push({ game_id: gameId, scores: [score] });
        }
      }
    }

    await progress.save({ session });
    return progress;
}
async function updateOverallProgress({ user_id, exercise_id, score }) {
  const overall = await OverallProgress.findOne({ user_id });

  if (!overall) {
    const newOverall = new OverallProgress({
      user_id,
      progress_by_exercise: [{
        exercise_id,
        stats: {
          total_correct: { count: 0, items: [] },
          total_incorrect: { count: 0, items: [] },
          total_items_attempted: 0,
          accuracy_percentage: 0,
          average_game_score: score,
          time_spent_seconds: 0
        }
      }],
      overall_stats: {
        total_time_spent: 0,
        combined_accuracy: 0,
        average_score_all: score
      }
    });
    await newOverall.save();
    return;
  }

  const ex = overall.progress_by_exercise.find(p => p.exercise_id.toString() === exercise_id.toString());
  if (ex) {
    const stats = ex.stats;
    const totalAttempts = stats.total_items_attempted + 1;
    const newAvgScore = ((stats.average_game_score * stats.total_items_attempted) + score) / totalAttempts;
    stats.total_items_attempted = totalAttempts;
    stats.average_game_score = newAvgScore;
  } else {
    overall.progress_by_exercise.push({
      exercise_id,
      stats: {
        total_correct: { count: 0, items: [] },
        total_incorrect: { count: 0, items: [] },
        total_items_attempted: 1,
        accuracy_percentage: 0,
        average_game_score: score,
        time_spent_seconds: 0
      }
    });
  }
  const allScores = overall.progress_by_exercise.map(p => p.stats.average_game_score);
  overall.overall_stats.average_score_all = allScores.reduce((a, b) => a + b, 0) / allScores.length;

  await overall.save();
}

export const updategamesProgress = async (userId, exerciseId, levelId, gameId, score) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // 1. Update daily game attempts
    await UserDailyGamesAttempts(userId, levelId, gameId, score, session);

    // 2. Update exercise progress
    await updateExerciseProgress(userId, exerciseId, levelId, gameId, score, session);

    // 3. Update overall progress
    await updateOverallProgress({ user_id: userId, exercise_id: exerciseId, score });

    await session.commitTransaction();
    return { success: true, message: 'Game progress updated successfully.' };

  } catch (error) {
    if (session.inTransaction()) {
      await session.abortTransaction();
    }
    console.error(error);
    throw new Error(error.message || 'Failed to update game progress');
  } finally {
    session.endSession();
  }
}
