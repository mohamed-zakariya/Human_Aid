import PDFDocument from 'pdfkit';
import fs from 'fs';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';
import Exercises from '../models/Exercises.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Enhanced color palette
const colors = {
  primary: '#2563eb', secondary: '#059669', accent: '#dc2626',
  light: '#f3f4f6', dark: '#1f2937', text: '#374151',
  success: '#10b981', warning: '#f59e0b', error: '#ef4444',
  purple: '#8b5cf6', orange: '#f97316', teal: '#14b8a6'
};

function fixArabicSentence(sentence) {
  const words = sentence.trim().split(' ');
  return words.length !== 3 ? sentence : `${words[2]} ${words[1]} ${words[0]}`;
}

function drawRoundedRect(doc, x, y, width, height, radius = 5) {
  doc.roundedRect(x, y, width, height, radius);
}

function createSectionHeader(doc, title, color = colors.primary, icon = '') {
  const currentY = doc.y;
  drawRoundedRect(doc, 50, currentY - 5, 495, 35, 8);
  doc.fillAndStroke(color, color);
  
  doc.fillColor('white').font('Helvetica-Bold').fontSize(14)
     .text(`${icon} ${title}`, 65, currentY + 8);
  doc.fillColor(colors.text).moveDown(2);
}

function createMetricCard(doc, title, value, subtitle, color, x, y, width = 120) {
  drawRoundedRect(doc, x, y, width, 60, 8);
  doc.fillAndStroke(colors.light, '#e5e7eb');
  
  // Color accent bar
  drawRoundedRect(doc, x, y, width, 8, 8);
  doc.fillAndStroke(color, color);
  
  doc.fillColor(color).font('Helvetica-Bold').fontSize(20)
     .text(value, x + 10, y + 15, { width: width - 20, align: 'center' });
  doc.fillColor(colors.text).font('Helvetica-Bold').fontSize(9)
     .text(title, x + 10, y + 35, { width: width - 20, align: 'center' });
  doc.font('Helvetica').fontSize(8).fillColor('#6b7280')
     .text(subtitle, x + 10, y + 47, { width: width - 20, align: 'center' });
}

async function getExerciseDetails() {
  try {
    const exercises = await Exercises.find({});
    const exerciseMap = new Map();

    exercises.forEach(exercise => {
      const exerciseId = exercise._id.toString();
      exerciseMap.set(exerciseId, {
        name: exercise.name,
        arabic_name: exercise.arabic_name,
        levels: new Map()
      });

      exercise.levels.forEach(level => {
        const levelIdString = level._id.toString(); // ✅ Use _id
        exerciseMap.get(exerciseId).levels.set(levelIdString, {
          name: level.name,
          arabic_name: level.arabic_name,
          level_number: level.level_number,
          games: new Map()
        });

        level.games.forEach(game => {
          const gameIdString = game._id.toString(); // ✅ Use _id
          exerciseMap.get(exerciseId).levels.get(levelIdString)
                    .games.set(gameIdString, {
            name: game.name,
            arabic_name: game.arabic_name
          });
        });
      });
    });

    return exerciseMap;
  } catch (error) {
    console.error('Error fetching exercise details:', error);
    return new Map();
  }
}


// Helper function to get exercise name from game attempt
function getExerciseFromGameAttempt(gameAttempt, exerciseDetails) {
  const gameObjectIdString = gameAttempt.game_id.toString();
  const levelObjectIdString = gameAttempt.level_id.toString();

  for (const [exerciseId, exercise] of exerciseDetails) {
    for (const [levelId, level] of exercise.levels) {
      if (levelId === levelObjectIdString) {
        for (const [gameId, game] of level.games) {
          if (gameId === gameObjectIdString) {
            return {
              exerciseName: exercise.name,
              levelName: level.name,
              gameName: game.name
            };
          }
        }
        return {
          exerciseName: exercise.name,
          levelName: level.name,
          gameName: 'Unknown Game'
        };
      }
    }
  }

  return {
    exerciseName: 'Unknown Exercise',
    levelName: 'Unknown Level',
    gameName: 'Unknown Game'
  };
}

// Helper function to get exercise name from level_id in attempts
function getExerciseFromLevelId(levelId, exerciseDetails) {
  const levelObjectIdString = levelId.toString();

  for (const [exerciseId, exercise] of exerciseDetails) {
    for (const [levelIdKey, level] of exercise.levels) {
      if (levelIdKey === levelObjectIdString) {
        return {
          exerciseName: exercise.name,
          levelName: level.name
        };
      }
    }
  }

  return {
    exerciseName: 'Unknown Exercise',
    levelName: 'Unknown Level'
  };
}


export const generateProgressPDF = async ({ learner, parent, dailyAttempts, overallProgress }) => {
  const doc = new PDFDocument({ margin: 40, size: 'A4' });
  const fileName = `${learner.name.replace(/\s+/g, '_')}_Weekly_Report.pdf`;
  const filePath = path.join(os.tmpdir(), fileName);

  try {
    const arabicFontPath = path.join(__dirname, 'Amiri-Regular.ttf');
    doc.registerFont('Arabic', arabicFontPath);
  } catch (error) {
    console.warn('Arabic font not found, using default font');
  }

  doc.pipe(fs.createWriteStream(filePath));

  const exerciseDetails = await getExerciseDetails();

  // Enhanced Header
  doc.rect(0, 0, 595, 130).fillAndStroke(colors.primary, colors.primary);
  const gradient = doc.linearGradient(0, 0, 0, 130);
  gradient.stop(0, colors.primary).stop(1, '#1d4ed8');
  doc.rect(0, 0, 595, 130).fill(gradient);

  doc.fillColor('white').font('Helvetica-Bold').fontSize(26)
     .text('Weekly Progress Report', 50, 35);
  
  doc.fontSize(14)
     .text(`Student: ${learner.name}`, 50, 70)
     .text(`Parent: ${parent.name}`, 50, 90)
     .text(`${new Date().toDateString()}`, 350, 70)
     .text(`${new Date().toLocaleTimeString()}`, 350, 90);

  doc.y = 150;

  // Key Metrics Dashboard
  if (overallProgress) {
    const stats = overallProgress.overall_stats;
    createSectionHeader(doc, 'Performance Dashboard', colors.primary);
    
    // Metric cards row
    const cardY = doc.y;
    createMetricCard(doc, 'Learning Time', `${(stats.total_time_spent / 60).toFixed(0)}m`, 
                     'Total minutes', colors.purple, 60, cardY);
    createMetricCard(doc, 'Accuracy', `${stats.combined_accuracy.toFixed(0)}%`, 
                     'Overall score', colors.success, 190, cardY);
    createMetricCard(doc, 'Avg Games', `${stats.average_score_all.toFixed(1)}`, 
                     'Out of 10', colors.orange, 320, cardY);
    createMetricCard(doc, 'Exercises', `${overallProgress.progress_by_exercise.length}`, 
                     'Completed', colors.teal, 450, cardY);

    doc.y = cardY + 95;
  }

  // MOVED UP: Daily Learning Activities - Enhanced with detailed breakdown and exercise names
  if (dailyAttempts.length > 0) {
    createSectionHeader(doc, 'Daily Learning Activities', colors.secondary);
    
    dailyAttempts.forEach((attempt, index) => {
      if (doc.y > 680) doc.addPage();
      
      const dayTitle = `Day ${index + 1} - ${new Date(attempt.date).toLocaleDateString()}`;
      const totalAttempts = attempt.words_attempts.length + attempt.letters_attempts.length + 
                           attempt.sentences_attempts.length;
      const correctAttempts = attempt.words_attempts.filter(w => w.is_correct).length +
                             attempt.letters_attempts.filter(l => l.is_correct).length +
                             attempt.sentences_attempts.filter(s => s.is_correct).length;
      const accuracy = totalAttempts > 0 ? (correctAttempts / totalAttempts) * 100 : 0;

      doc.font('Helvetica-Bold').fontSize(12).fillColor(colors.secondary)
         .text(dayTitle, 65);
      doc.moveDown(0.5);
      
      if (totalAttempts > 0 || (attempt.game_attempts && attempt.game_attempts.length > 0)) {
        doc.font('Helvetica').fontSize(10).fillColor(colors.text)
           .text(`Total Practice Attempts: ${totalAttempts} | Correct: ${correctAttempts} | Accuracy: ${accuracy.toFixed(1)}%`, 85);
        doc.moveDown(0.8);

        // Words Practice with Exercise Names
        if (attempt.words_attempts.length > 0) {
          doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.primary)
             .text('Words Practice:', 85);
          doc.moveDown(0.3);
          
          const correctWords = attempt.words_attempts.filter(w => w.is_correct);
          const incorrectWords = attempt.words_attempts.filter(w => !w.is_correct);
          
          if (correctWords.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.success)
               .text(`✓ Correct (${correctWords.length}):`, 100);
            
            // Group by exercise
            const wordsByExercise = new Map();
            correctWords.forEach(w => {
              const exerciseInfo = getExerciseFromLevelId(w.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!wordsByExercise.has(key)) {
                wordsByExercise.set(key, []);
              }
              wordsByExercise.get(key).push(w.correct_word);
            });
            
            for (const [exerciseKey, words] of wordsByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              try {
                doc.font('Arabic').fontSize(9).fillColor(colors.text);
              } catch (e) {
                doc.font('Helvetica').fontSize(9).fillColor(colors.text);
              }
              doc.text(words.join('، '), 120, doc.y, { width: 410 });
              doc.moveDown(0.4);
            }
          }
          
          if (incorrectWords.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.error)
               .text(`✗ Needs Practice (${incorrectWords.length}):`, 100);
            
            // Group by exercise
            const wordsByExercise = new Map();
            incorrectWords.forEach(w => {
              const exerciseInfo = getExerciseFromLevelId(w.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!wordsByExercise.has(key)) {
                wordsByExercise.set(key, []);
              }
              wordsByExercise.get(key).push(`${w.correct_word} (said: ${w.spoken_word})`);
            });
            
            for (const [exerciseKey, words] of wordsByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              try {
                doc.font('Arabic').fontSize(9).fillColor(colors.text);
              } catch (e) {
                doc.font('Helvetica').fontSize(9).fillColor(colors.text);
              }
              doc.text(words.join('، '), 120, doc.y, { width: 410 });
              doc.moveDown(0.4);
            }
          }
          doc.moveDown(0.3);
        }

        // Letters Practice with Exercise Names
        if (attempt.letters_attempts.length > 0) {
          doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.purple)
             .text('Letters Practice:', 85);
          doc.moveDown(0.3);
          
          const correctLetters = attempt.letters_attempts.filter(l => l.is_correct);
          const incorrectLetters = attempt.letters_attempts.filter(l => !l.is_correct);
          
          if (correctLetters.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.success)
               .text(`✓ Correct (${correctLetters.length}):`, 100);
            
            // Group by exercise
            const lettersByExercise = new Map();
            correctLetters.forEach(l => {
              const exerciseInfo = getExerciseFromLevelId(l.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!lettersByExercise.has(key)) {
                lettersByExercise.set(key, []);
              }
              lettersByExercise.get(key).push(l.correct_letter);
            });
            
            for (const [exerciseKey, letters] of lettersByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              try {
                doc.font('Arabic').fontSize(9).fillColor(colors.text);
              } catch (e) {
                doc.font('Helvetica').fontSize(9).fillColor(colors.text);
              }
              doc.text(letters.join('، '), 120, doc.y, { width: 410 });
              doc.moveDown(0.4);
            }
          }
          
          if (incorrectLetters.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.error)
               .text(`✗ Needs Practice (${incorrectLetters.length}):`, 100);
            
            // Group by exercise
            const lettersByExercise = new Map();
            incorrectLetters.forEach(l => {
              const exerciseInfo = getExerciseFromLevelId(l.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!lettersByExercise.has(key)) {
                lettersByExercise.set(key, []);
              }
              lettersByExercise.get(key).push(`${l.correct_letter} (said: ${l.spoken_letter})`);
            });
            
            for (const [exerciseKey, letters] of lettersByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              try {
                doc.font('Arabic').fontSize(9).fillColor(colors.text);
              } catch (e) {
                doc.font('Helvetica').fontSize(9).fillColor(colors.text);
              }
              doc.text(letters.join('، '), 120, doc.y, { width: 410 });
              doc.moveDown(0.4);
            }
          }
          doc.moveDown(0.3);
        }

        // Sentences Practice with Exercise Names
        if (attempt.sentences_attempts.length > 0) {
          doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.orange)
             .text('Sentences Practice:', 85);
          doc.moveDown(0.3);
          
          const correctSentences = attempt.sentences_attempts.filter(s => s.is_correct);
          const incorrectSentences = attempt.sentences_attempts.filter(s => !s.is_correct);
          
          if (correctSentences.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.success)
               .text(`✓ Correct (${correctSentences.length}):`, 100);
            
            // Group by exercise
            const sentencesByExercise = new Map();
            correctSentences.forEach(s => {
              const exerciseInfo = getExerciseFromLevelId(s.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!sentencesByExercise.has(key)) {
                sentencesByExercise.set(key, []);
              }
              sentencesByExercise.get(key).push(s.correct_sentence);
            });
            
            for (const [exerciseKey, sentences] of sentencesByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              sentences.forEach(sentence => {
                try {
                  doc.font('Arabic').fontSize(9).fillColor(colors.text);
                } catch (e) {
                  doc.font('Helvetica').fontSize(9).fillColor(colors.text);
                }
                doc.text(`• ${sentence}`, 120, doc.y, { width: 410 });
                doc.moveDown(0.3);
              });
              doc.moveDown(0.2);
            }
          }
          
          if (incorrectSentences.length > 0) {
            doc.font('Helvetica').fontSize(9).fillColor(colors.error)
               .text(`✗ Needs Practice (${incorrectSentences.length}):`, 100);
            
            // Group by exercise
            const sentencesByExercise = new Map();
            incorrectSentences.forEach(s => {
              const exerciseInfo = getExerciseFromLevelId(s.level_id, exerciseDetails);
              const key = `${exerciseInfo.exerciseName} - ${exerciseInfo.levelName}`;
              if (!sentencesByExercise.has(key)) {
                sentencesByExercise.set(key, []);
              }
              sentencesByExercise.get(key).push(s);
            });
            
            for (const [exerciseKey, sentences] of sentencesByExercise) {
              doc.font('Helvetica-Bold').fontSize(8).fillColor(colors.text)
                 .text(`${exerciseKey}:`, 110);
              sentences.forEach(s => {
                try {
                  doc.font('Arabic').fontSize(9).fillColor(colors.text);
                } catch (e) {
                  doc.font('Helvetica').fontSize(9).fillColor(colors.text);
                }
                doc.text(`• ${s.correct_sentence}`, 120, doc.y, { width: 410 });
                doc.font('Helvetica').fontSize(8).fillColor('#6b7280')
                   .text(`(Said: ${s.spoken_sentence})`, 130, doc.y, { width: 400 });
                doc.moveDown(0.4);
              });
              doc.moveDown(0.2);
            }
          }
          doc.moveDown(0.3);
        }

        // Game Attempts with Full Exercise and Game Names
        if (attempt.game_attempts && attempt.game_attempts.length > 0) {
          doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.teal)
             .text('Games Played:', 85);
          doc.moveDown(0.3);
          
          attempt.game_attempts.forEach(gameAttempt => {
            const gameInfo = getExerciseFromGameAttempt(gameAttempt, exerciseDetails);
            const scores = gameAttempt.attempts.map(a => a.score);
            const avgScore = scores.length > 0 ? (scores.reduce((a, b) => a + b, 0) / scores.length).toFixed(1) : 'N/A';
            const bestScore = scores.length > 0 ? Math.max(...scores) : 'N/A';
            
            doc.font('Helvetica').fontSize(9).fillColor(colors.text)
               .text(`${gameInfo.exerciseName} - ${gameInfo.levelName}`, 100, doc.y, { width: 430 });
            doc.moveDown(0.3);
            doc.font('Helvetica').fontSize(8).fillColor('#6b7280')
               .text(`Game: ${gameInfo.gameName} | Avg: ${avgScore}/10 | Best: ${bestScore}/10 | Attempts: ${scores.length}`, 110, doc.y, { width: 420 });
            doc.moveDown(0.5);
          });
          doc.moveDown(0.3);
        }
      } else {
        doc.font('Helvetica').fontSize(10).fillColor('#6b7280')
           .text('No practice activities recorded for this day', 85);
        doc.moveDown(0.8);
      }
      
      // Day separator
      doc.moveTo(60, doc.y).lineTo(535, doc.y).strokeColor('#e5e7eb').stroke();
      doc.moveDown(1);
    });
  }

  // Weekly Activity Summary (moved after daily activities)
  if (dailyAttempts.length > 0) {
    if (doc.y > 600) doc.addPage();
    createSectionHeader(doc, 'Weekly Activity Summary', colors.secondary);
    
    const totalDays = dailyAttempts.length;
    const totalAttempts = dailyAttempts.reduce((sum, day) => 
      sum + day.words_attempts.length + day.letters_attempts.length + 
      day.sentences_attempts.length, 0);
    const totalCorrect = dailyAttempts.reduce((sum, day) => 
      sum + day.words_attempts.filter(w => w.is_correct).length +
      day.letters_attempts.filter(l => l.is_correct).length +
      day.sentences_attempts.filter(s => s.is_correct).length, 0);
    const totalGameAttempts = dailyAttempts.reduce((sum, day) => 
      sum + (day.game_attempts ? day.game_attempts.length : 0), 0);

    const summaryItems = [
      `Active Days: ${totalDays}/7 days`,
      `Total Practice Attempts: ${totalAttempts}`,
      `Correct Answers: ${totalCorrect}`,
      `Weekly Accuracy: ${totalAttempts > 0 ? ((totalCorrect/totalAttempts)*100).toFixed(1) : 0}%`,
      `Games Played: ${totalGameAttempts}`
    ];

    summaryItems.forEach(item => {
      doc.font('Helvetica').fontSize(11).fillColor(colors.text)
         .text(item, 65, doc.y);
      doc.moveDown(0.6);
    });
    doc.moveDown(0.5);
  }

  // Exercise Progress Details (moved down)
  if (overallProgress && overallProgress.progress_by_exercise.length > 0) {
    if (doc.y > 600) doc.addPage();
    createSectionHeader(doc, 'Stage Progress Breakdown', colors.accent);
    
    for (let i = 0; i < overallProgress.progress_by_exercise.length; i++) {
      const entry = overallProgress.progress_by_exercise[i];
      const exerciseInfo = exerciseDetails.get(entry.exercise_id.toString());
      
      if (doc.y > 650) doc.addPage();
      
      // Exercise header
      const exerciseName = exerciseInfo ? exerciseInfo.name : `Exercise ${i + 1}`;
      
      doc.font('Helvetica-Bold').fontSize(13).fillColor(colors.accent)
         .text(`${exerciseName}`, 65, doc.y);
      
      doc.y += 25;

      // Stats grid
      const statsY = doc.y;
      createMetricCard(doc, 'Accuracy', `${entry.stats.accuracy_percentage.toFixed(0)}%`, 
                       'Success rate', colors.success, 60, statsY, 110);
      createMetricCard(doc, 'Time Spent', `${(entry.stats.time_spent_seconds/60).toFixed(0)}m`, 
                       'Minutes', colors.purple, 180, statsY, 110);
      createMetricCard(doc, 'Games Avg', `${entry.stats.average_game_score.toFixed(1)}`, 
                       'Out of 10', colors.orange, 300, statsY, 110);
      createMetricCard(doc, 'Progress', `${entry.stats.progress_percentage.toFixed(0)}%`, 
                       'Complete', colors.teal, 420, statsY, 110);

      doc.y = statsY + 75;

      // Mastered vs Needs Practice - Show all items
      if (entry.stats.total_correct.items.length > 0) {
        doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.success)
           .text('Mastered Items:', 65);
        doc.moveDown(0.3);
        try {
          doc.font('Arabic').fontSize(10).fillColor(colors.text);
        } catch (e) {
          doc.font('Helvetica').fontSize(10).fillColor(colors.text);
        }
        
        const masteredText = entry.stats.total_correct.items.join('، ');
        doc.text(masteredText, 85, doc.y, { width: 450 });
        doc.moveDown(1);
      }

      if (entry.stats.total_incorrect.items.length > 0) {
        doc.font('Helvetica-Bold').fontSize(10).fillColor(colors.error)
           .text('Needs Practice:', 65);
        doc.moveDown(0.3);
        try {
          doc.font('Arabic').fontSize(10).fillColor(colors.text);
        } catch (e) {
          doc.font('Helvetica').fontSize(10).fillColor(colors.text);
        }
        
        const needsPracticeText = entry.stats.total_incorrect.items.join('، ');
        doc.text(needsPracticeText, 85, doc.y, { width: 450 });
        doc.moveDown(1);
      }

      // Separator
      doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor('#e5e7eb').stroke();
      doc.moveDown(1);
    }
  }

  // Recommendations section
  if (overallProgress) {
    if (doc.y > 650) doc.addPage();
    createSectionHeader(doc, 'Recommendations', colors.warning);
    
    const recommendations = [];
    const stats = overallProgress.overall_stats;
    
    if (stats.combined_accuracy < 70) {
      recommendations.push('Focus on accuracy by practicing at a slower pace');
    }
    if (stats.total_time_spent < 300) { // Less than 5 minutes total
      recommendations.push('=Try to spend more time practicing each day');
    }
    if (stats.average_score_all < 6) {
      recommendations.push('Review fundamental concepts before attempting games');
    }
    
    if (recommendations.length === 0) {
      recommendations.push('Great progress! Keep up the excellent work!');
    }

    recommendations.forEach(rec => {
      doc.font('Helvetica').fontSize(11).fillColor(colors.text)
         .text(`${rec}`, 65, doc.y);
      doc.moveDown(0.8);
    });
  }

  doc.end();
  return filePath;
};