import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';

import '../../../generated/l10n.dart';
import '../../../global/fns.dart';
import 'learner_progress_details_page.dart';

class Childcard extends StatefulWidget {
  final String title;
  final String learnerName;
  final String username;
  final int wordsRead;
  final int correctWords;
  final int incorrectWords;
  final bool dailyQuestCompleted;
  final bool awardReceived;
  final Color color;
  final IconData icon;
  final List<Word> correctWordList;
  final List<Word> incorrectWordList;
  final List<Letter> correctLetters;
  final List<Letter> incorrectLetters;
  final List<Sentence> correctSentences;
  final List<Sentence> incorrectSentences;

  final List<Map<String, dynamic>> gameAttempts;

  const Childcard({
    super.key,
    required this.title,
    required this.learnerName,
    required this.username,
    required this.wordsRead,
    required this.correctWords,
    required this.incorrectWords,
    required this.dailyQuestCompleted,
    required this.awardReceived,
    required this.color,
    required this.icon,
    required this.correctWordList,
    required this.incorrectWordList,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.gameAttempts,
    required this.correctSentences,
    required this.incorrectSentences,

  });

  @override
  State<Childcard> createState() => _ChildcardState();
}

class _ChildcardState extends State<Childcard> {
  @override
  void initState() {
    super.initState();
    print(widget.correctLetters);
    print(widget.incorrectLetters);
    print(widget.correctWordList);
    print(widget.incorrectWordList);
  }

  @override
  Widget build(BuildContext context) {
    final totalCorrect = widget.correctWordList.length + widget.correctLetters.length + widget.correctSentences.length;
    final totalIncorrect = widget.incorrectWordList.length + widget.incorrectLetters.length + widget.incorrectSentences.length;
    final total = totalCorrect + totalIncorrect;

    final accuracy = total > 0 ? (totalCorrect / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with learner info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.learnerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@${widget.username}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Accuracy badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accuracy >= 80 ? Colors.green.withOpacity(0.1) :
                    accuracy >= 60 ? Colors.orange.withOpacity(0.1) :
                    Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$accuracy%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accuracy >= 80 ? Colors.green[700] :
                      accuracy >= 60 ? Colors.orange[700] :
                      Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Correct",
                    totalCorrect.toString(),
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Incorrect",
                    totalIncorrect.toString(),
                    Colors.red,
                    Icons.cancel_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status indicators
            Row(
              children: [
                _buildStatusChip(
                  widget.dailyQuestCompleted ? "Quest Complete" : "Quest Pending",
                  widget.dailyQuestCompleted ? Colors.blue : Colors.grey,
                  widget.dailyQuestCompleted ? Icons.task_alt : Icons.schedule,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  widget.awardReceived ? "Award Won" : "No Award",
                  widget.awardReceived ? Colors.amber : Colors.grey,
                  widget.awardReceived ? Icons.emoji_events : Icons.lock_outline,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    createRouteParentLearnerProgress(LearnerProgressDetailsPage(
                      learnerName: widget.learnerName,
                      username: widget.username,
                      correctWords: widget.correctWordList,
                      incorrectWords: widget.incorrectWordList,
                      correctLetters: widget.correctLetters,
                      incorrectLetters: widget.incorrectLetters,
                      correctSentences: widget.correctSentences,
                      incorrectSentences: widget.incorrectSentences,
                      gameAttempts: widget.gameAttempts,
                    )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).view_details,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}