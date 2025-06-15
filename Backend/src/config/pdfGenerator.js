import PDFDocument from 'pdfkit';
import fs from 'fs';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Color palette
const colors = {
  primary: '#2563eb',     // Blue
  secondary: '#059669',   // Green
  accent: '#dc2626',      // Red
  light: '#f3f4f6',      // Light gray
  dark: '#1f2937',       // Dark gray
  text: '#374151',       // Medium gray
  success: '#10b981',    // Success green
  warning: '#f59e0b',    // Warning orange
  error: '#ef4444'       // Error red
};

function fixArabicSentence(sentence) {
  const words = sentence.trim().split(' ');
  if (words.length !== 3) return sentence;
  return `${words[2]} ${words[1]} ${words[0]}`;
}

// Helper function to draw a rounded rectangle
function drawRoundedRect(doc, x, y, width, height, radius = 5) {
  doc.roundedRect(x, y, width, height, radius);
}

// Helper function to create section headers
function createSectionHeader(doc, title, color = colors.primary) {
  const currentY = doc.y;
  
  // Background rectangle
  drawRoundedRect(doc, 50, currentY - 5, 495, 30, 8);
  doc.fillAndStroke(color, color);
  
  // Header text
  doc.fillColor('white')
     .font('Helvetica-Bold')
     .fontSize(14)
     .text(title, 60, currentY + 5);
  
  doc.fillColor(colors.text);
  doc.moveDown(1.5);
}

// Helper function to create info boxes
function createInfoBox(doc, items, bgColor = colors.light) {
  const startY = doc.y;
  const boxHeight = items.length * 20 + 20;
  
  // Background box
  drawRoundedRect(doc, 50, startY, 495, boxHeight, 5);
  doc.fillAndStroke(bgColor, bgColor);
  
  doc.fillColor(colors.text);
  doc.y = startY + 10;
  
  items.forEach(item => {
    doc.font('Helvetica')
       .fontSize(11)
       .text(`• ${item}`, 65, doc.y, { width: 465 });
    doc.moveDown(0.8);
  });
  
  doc.moveDown(0.5);
}

// Helper function to create progress bars
function createProgressBar(doc, label, percentage, color = colors.primary) {
  const barWidth = 200;
  const barHeight = 12;
  const startX = 300;
  const startY = doc.y;
  
  // Label
  doc.font('Helvetica')
     .fontSize(10)
     .fillColor(colors.text)
     .text(label, 65, startY);
  
  // Background bar
  drawRoundedRect(doc, startX, startY - 2, barWidth, barHeight, 6);
  doc.fillAndStroke(colors.light, colors.light);
  
  // Progress bar
  const progressWidth = (barWidth * percentage) / 100;
  if (progressWidth > 0) {
    drawRoundedRect(doc, startX, startY - 2, progressWidth, barHeight, 6);
    doc.fillAndStroke(color, color);
  }
  
  // Percentage text
  doc.fillColor('white')
     .font('Helvetica-Bold')
     .fontSize(8)
     .text(`${percentage.toFixed(1)}%`, startX + barWidth/2 - 15, startY + 1);
  
  doc.fillColor(colors.text);
  doc.moveDown(1.2);
}

// Helper function to create status badges
function createStatusBadge(doc, status, x, y) {
  const isCorrect = status === 'Correct';
  const badgeColor = isCorrect ? colors.success : colors.error;
  const textColor = 'white';
  
  doc.fontSize(8);
  const textWidth = doc.widthOfString(status);
  const badgeWidth = textWidth + 12;
  const badgeHeight = 16;
  
  drawRoundedRect(doc, x, y - 2, badgeWidth, badgeHeight, 8);
  doc.fillAndStroke(badgeColor, badgeColor);
  
  doc.fillColor(textColor)
     .font('Helvetica-Bold')
     .text(status, x + 6, y + 2);
  
  doc.fillColor(colors.text);
  return badgeWidth + 5;
}

export const generateProgressPDF = async ({ learner, parent, dailyAttempts, overallProgress }) => {
  const doc = new PDFDocument({ 
    margin: 40, 
    size: 'A4',
    info: {
      Title: `${learner.name} - Weekly Progress Report`,
      Author: 'Learning App',
      Subject: 'Student Progress Report'
    }
  });

  const fileName = `${learner.name.replace(/\s+/g, '_')}_Weekly_Report.pdf`;
  const filePath = path.join(os.tmpdir(), fileName);
  const arabicFontPath = path.join(__dirname, 'Amiri-Regular.ttf');

  doc.registerFont('Arabic', arabicFontPath);
  
  doc.pipe(fs.createWriteStream(filePath));

  // Header with gradient-like effect
  doc.rect(0, 0, 595, 120).fillAndStroke(colors.primary, colors.primary);
  doc.rect(0, 120, 595, 10).fillAndStroke('#3b82f6', '#3b82f6');
  
  // Add logo (if logo file exists)
  const logoPath = path.join(__dirname, 'lexXfix-logo.jpg');
  try {
    if (fs.existsSync(logoPath)) {
      doc.image(logoPath, 50, 25, { width: 120, height: 40 });
    }
  } catch (error) {
    console.warn('Logo file not found, proceeding without logo');
  }
  
  // Title
  doc.fillColor('white')
     .font('Helvetica-Bold')
     .fontSize(24)
     .text('Weekly Progress Report', 200, 40, { align: 'center' });
  
  // Student info section
  doc.fontSize(12)
     .text(`Student: ${learner.name}`, 50, 75)
     .text(`Parent: ${parent.name}`, 50, 92)
     .text(`Report Date: ${new Date().toDateString()}`, 350, 75)
     .text(`Generated: ${new Date().toLocaleTimeString()}`, 350, 92);

  doc.y = 150;
  doc.fillColor(colors.text);

  // Overall Progress Summary (if available)
  if (overallProgress) {
    const stats = overallProgress.overall_stats;
    createSectionHeader(doc, 'Overall Performance Summary', colors.primary);
    
    const summaryItems = [
      `Total Learning Time: ${(stats.total_time_spent / 60).toFixed(1)} minutes`,
      `Overall Accuracy: ${stats.combined_accuracy.toFixed(1)}%`,
      `Average Games Score: ${stats.average_score_all.toFixed(1)}/10`,
      `Exercises Completed: ${overallProgress.progress_by_exercise.length}`
    ];
    
    createInfoBox(doc, summaryItems, '#eff6ff');
    
    // Progress bars for key metrics
    doc.moveDown(0.5);
    createProgressBar(doc, 'Overall Accuracy', stats.combined_accuracy, colors.success);
    createProgressBar(doc, 'Average Games Score', (stats.average_score_all / 10) * 100, colors.primary);
  }

  // Daily Attempts Section
  if (dailyAttempts.length) {
    createSectionHeader(doc, 'Daily Learning Activities', colors.secondary);
    
    dailyAttempts.forEach((attempt, index) => {
      // Check if we need a new page
      if (doc.y > 700) {
        doc.addPage();
      }
      
      const dayTitle = `Day ${index + 1} - ${new Date(attempt.date).toLocaleDateString()}`;
      
      // Day header
      doc.font('Helvetica-Bold')
         .fontSize(12)
         .fillColor(colors.secondary)
         .text(dayTitle, 65);
      doc.moveDown(0.5);

      // Activity summary
      const totalAttempts = attempt.words_attempts.length + 
                           attempt.letters_attempts.length + 
                           attempt.sentences_attempts.length;
      const correctAttempts = attempt.words_attempts.filter(w => w.is_correct).length +
                             attempt.letters_attempts.filter(l => l.is_correct).length +
                             attempt.sentences_attempts.filter(s => s.is_correct).length;
      
      const accuracy = totalAttempts > 0 ? (correctAttempts / totalAttempts) * 100 : 0;
      
      createProgressBar(doc, `Daily Accuracy (${correctAttempts}/${totalAttempts})`, accuracy, colors.secondary);

      // Words section
      if (attempt.words_attempts.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(11)
           .fillColor(colors.text)
           .text('Words Practice:', 75);
        doc.moveDown(0.3);
        
        attempt.words_attempts.forEach((w, i) => {
          const yPos = doc.y;
          doc.font('Helvetica')
             .fontSize(10)
             .text(`${i + 1}.`, 85, yPos);
          
          doc.font('Arabic')
             .fontSize(12)
             .text(w.correct_word, 105, yPos);
          
          const badgeX = 200;
          createStatusBadge(doc, w.is_correct ? 'Correct' : 'Incorrect', badgeX, yPos);
          
          if (!w.is_correct) {
            doc.font('Helvetica')
               .fontSize(9)
               .fillColor('#6b7280')
               .text('Your answer: ', 300, yPos);
            doc.font('Arabic')
               .text(w.spoken_word, 360, yPos);
          }
          
          doc.fillColor(colors.text);
          doc.moveDown(0.8);
        });
        doc.moveDown(0.3);
      }

      // Letters section
      if (attempt.letters_attempts.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(11)
           .fillColor(colors.text)
           .text('Letters Practice:', 75);
        doc.moveDown(0.3);
        
        attempt.letters_attempts.forEach((l, i) => {
          const yPos = doc.y;
          doc.font('Helvetica')
             .fontSize(10)
             .text(`${i + 1}.`, 85, yPos);
          
          doc.font('Arabic')
             .fontSize(12)
             .text(l.correct_letter, 105, yPos);
          
          const badgeX = 200;
          createStatusBadge(doc, l.is_correct ? 'Correct' : 'Incorrect', badgeX, yPos);
          
          if (!l.is_correct) {
            doc.font('Helvetica')
               .fontSize(9)
               .fillColor('#6b7280')
               .text('Your answer: ', 300, yPos);
            doc.font('Arabic')
               .text(l.spoken_letter, 360, yPos);
          }
          
          doc.fillColor(colors.text);
          doc.moveDown(0.8);
        });
        doc.moveDown(0.3);
      }

      // Sentences section
      if (attempt.sentences_attempts.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(11)
           .fillColor(colors.text)
           .text('Sentences Practice:', 75);
        doc.moveDown(0.3);
        
        attempt.sentences_attempts.forEach((s, i) => {
          const yPos = doc.y;
          doc.font('Helvetica')
             .fontSize(10)
             .text(`${i + 1}.`, 85, yPos);
          
          doc.font('Arabic')
             .fontSize(11)
             .text(fixArabicSentence(s.correct_sentence), 105, yPos, { width: 200 });
          
          const badgeX = 320;
          createStatusBadge(doc, s.is_correct ? 'Correct' : 'Incorrect', badgeX, yPos);
          
          if (!s.is_correct) {
            doc.moveDown(0.5);
            doc.font('Helvetica')
               .fontSize(9)
               .fillColor('#6b7280')
               .text('Your answer: ', 105);
            doc.font('Arabic')
               .fontSize(10)
               .text(fixArabicSentence(s.spoken_sentence), 105, doc.y + 12, { width: 300 });
          }
          
          doc.fillColor(colors.text);
          doc.moveDown(1.2);
        });
        doc.moveDown(0.3);
      }

      // Games section
      if (attempt.game_attempts.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(11)
           .fillColor(colors.text)
           .text('Games Played:', 75);
        doc.moveDown(0.3);
        
        attempt.game_attempts.forEach((game, gi) => {
          const scores = game.attempts.map(a => a.score).filter(s => s !== undefined);
          if (scores.length > 0) {
            const avgScore = scores.reduce((a, b) => a + b, 0) / scores.length;
            doc.font('Helvetica')
               .fontSize(10)
               .text(`Game ${gi + 1}: Average Games Score ${avgScore.toFixed(1)}/10 (${scores.length} attempts)`, 85);
            doc.moveDown(0.5);
          }
        });
        doc.moveDown(0.5);
      }

      // Add separator line
      doc.moveTo(50, doc.y)
         .lineTo(545, doc.y)
         .strokeColor('#e5e7eb')
         .stroke();
      doc.moveDown(1);
    });
  } else {
    createSectionHeader(doc, 'Daily Activities', colors.secondary);
    createInfoBox(doc, ['No learning activities recorded this week.'], '#fef3c7');
  }

  // Detailed Progress Breakdown
  if (overallProgress && overallProgress.progress_by_exercise.length > 0) {
    // Add new page for detailed breakdown
    doc.addPage();
    
    createSectionHeader(doc, 'Detailed Exercise Breakdown', colors.accent);
    
    overallProgress.progress_by_exercise.forEach((entry, i) => {
      if (doc.y > 650) {
        doc.addPage();
      }
      
      // Exercise header
      doc.font('Helvetica-Bold')
         .fontSize(12)
         .fillColor(colors.accent)
         .text(`Exercise ${i + 1}`, 65);
      doc.moveDown(0.5);
      
      // Progress bars
      createProgressBar(doc, 'Accuracy', entry.stats.accuracy_percentage, colors.success);
      createProgressBar(doc, 'Average Games Score', (entry.stats.average_game_score / 10) * 100, colors.primary);
      
      // Stats summary
      const exerciseInfo = [
        `Time Spent: ${(entry.stats.time_spent_seconds / 60).toFixed(1)} minutes`,
        `Correct Answers: ${entry.stats.total_correct.count}`,
        `Incorrect Answers: ${entry.stats.total_incorrect.count}`
      ];
      
      createInfoBox(doc, exerciseInfo, '#f0fdf4');
      
      // Correct items
      if (entry.stats.total_correct.items.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(10)
           .fillColor(colors.success)
           .text('Mastered Items:', 65);
        doc.moveDown(0.3);
        doc.font('Arabic')
           .fontSize(11)
           .fillColor(colors.text)
           .text(entry.stats.total_correct.items.join('، '), 75, doc.y, { width: 470 });
        doc.moveDown(1);
      }
      
      // Incorrect items
      if (entry.stats.total_incorrect.items.length > 0) {
        doc.font('Helvetica-Bold')
           .fontSize(10)
           .fillColor(colors.error)
           .text('Needs Practice:', 65);
        doc.moveDown(0.3);
        doc.font('Arabic')
           .fontSize(11)
           .fillColor(colors.text)
           .text(entry.stats.total_incorrect.items.join('، '), 75, doc.y, { width: 470 });
        doc.moveDown(1);
      }
      
      doc.moveDown(0.5);
    });
  }

  doc.end();
  return filePath;
};