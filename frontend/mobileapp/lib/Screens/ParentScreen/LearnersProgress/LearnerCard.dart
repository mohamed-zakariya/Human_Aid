import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import 'package:mobileapp/models/dailyAttempts/GameAttempt.dart';

import '../../../generated/l10n.dart';
import '../../../global/fns.dart';
import 'learner_progress_details_page.dart';

class Childcard extends StatefulWidget {
  final String title;
  final String learnerName;
  final String username;
  final int totalCorrect;
  final int totalIncorrect;
  final int accuracy;
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
  final List<GameAttempt> gameAttempts;

  const Childcard({
    super.key,
    required this.title,
    required this.learnerName,
    required this.username,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.accuracy,
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
  late Map<String, int> stats;
  late Map<String, Map<String, dynamic>> gameStats;

  @override
  void initState() {
    super.initState();
    _calculateStats();
    _calculateGameStats();
  }

  void _calculateStats() {
    // Use the provided totals from ProgressDetails (which are already calculated correctly)
    final totalAttempts = widget.totalCorrect + widget.totalIncorrect;

    stats = {
      'totalCorrect': widget.totalCorrect,
      'totalIncorrect': widget.totalIncorrect,
      'total': totalAttempts,
      'accuracy': widget.accuracy,
      'lettersTotal': widget.correctLetters.length + widget.incorrectLetters.length,
      'wordsTotal': widget.correctWordList.length + widget.incorrectWordList.length,
      'sentencesTotal': widget.correctSentences.length + widget.incorrectSentences.length,
    };
  }

  void _calculateGameStats() {
    gameStats = {};

    for (var gameAttempt in widget.gameAttempts) {
      final levelName = gameAttempt.levelName ?? 'Unknown Level';
      final gameName = gameAttempt.gameName ?? 'Unknown Game';
      final key = '$levelName|$gameName';

      if (!gameStats.containsKey(key)) {
        gameStats[key] = {
          'levelName': levelName,
          'gameName': gameName,
          'attempts': 0,
          'totalScore': 0,
          'bestScore': 0,
          'scores': <int>[],
        };
      }

      for (var attempt in gameAttempt.attempts) {
        final score = attempt.score;

        gameStats[key]!['attempts'] = (gameStats[key]!['attempts'] as int) + 1;
        gameStats[key]!['totalScore'] = (gameStats[key]!['totalScore'] as int) + score;
        (gameStats[key]!['scores'] as List<int>).add(score);

        if (score > (gameStats[key]!['bestScore'] as int)) {
          gameStats[key]!['bestScore'] = score;
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                          color: Color(0xFF2C3E50),
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
                    color: _getAccuracyColor(stats['accuracy']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${stats['accuracy']}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getAccuracyColor(stats['accuracy']!),
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
                    "Total",
                    stats['total'].toString(),
                    const Color(0xFF3498DB),
                    Icons.assessment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Correct",
                    stats['totalCorrect'].toString(),
                    const Color(0xFF27AE60),
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Incorrect",
                    stats['totalIncorrect'].toString(),
                    const Color(0xFFE74C3C),
                    Icons.cancel_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exercise breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exercise Breakdown",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildExerciseChip("Letters", stats['lettersTotal']!, const Color(0xFF9B59B6)),
                      _buildExerciseChip("Words", stats['wordsTotal']!, const Color(0xFFE67E22)),
                      _buildExerciseChip("Sentences", stats['sentencesTotal']!, const Color(0xFF1ABC9C)),
                      _buildExerciseChip("Games", widget.gameAttempts.length, const Color(0xFF3F51B5)),
                    ],
                  ),
                ],
              ),
            ),

            // Game summary if games exist
            if (widget.gameAttempts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videogame_asset, size: 16, color: const Color(0xFF3F51B5)),
                        const SizedBox(width: 8),
                        Text(
                          "Game Summary",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3F51B5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.gameAttempts.length} game sessions • ${widget.gameAttempts.fold(0, (sum, game) => sum + game.attempts.length)} total attempts",
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF3F51B5).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Status indicators
            Row(
              children: [
                _buildStatusChip(
                  widget.dailyQuestCompleted ? "Quest Complete" : "Quest Pending",
                  widget.dailyQuestCompleted ? const Color(0xFF3498DB) : Colors.grey,
                  widget.dailyQuestCompleted ? Icons.task_alt : Icons.schedule,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  widget.awardReceived ? "Award Won" : "No Award",
                  widget.awardReceived ? const Color(0xFFF39C12) : Colors.grey,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 80) return const Color(0xFF27AE60);
    if (accuracy >= 60) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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

  Widget _buildExerciseChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
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