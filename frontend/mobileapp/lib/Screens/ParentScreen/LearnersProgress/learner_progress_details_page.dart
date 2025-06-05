import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/dailyAttempts/GameAttempt.dart';

import '../../../models/dailyAttempts/learner_daily_attempts.dart';

class LearnerProgressDetailsPage extends StatefulWidget {
  final String learnerName;
  final String username;
  final List<Word> correctWords;
  final List<Word> incorrectWords;
  final List<Letter> correctLetters;
  final List<Letter> incorrectLetters;
  final List<Sentence> correctSentences;
  final List<Sentence> incorrectSentences;
  final List<GameAttempt> gameAttempts;

  const LearnerProgressDetailsPage({
    required this.learnerName,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.correctSentences,
    required this.incorrectSentences,
    required this.gameAttempts,
    super.key,
  });

  @override
  State<LearnerProgressDetailsPage> createState() => _LearnerProgressDetailsPageState();
}

class _LearnerProgressDetailsPageState extends State<LearnerProgressDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, Map<String, dynamic>> gameStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateGameStats();
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
          'averageScore': 0.0,
          'scores': <int>[],
          'timestamps': <String>[],
        };
      }

      // Iterate through all attempts within this game attempt
      for (var attempt in gameAttempt.attempts) {
        final score = attempt.score;

        gameStats[key]!['attempts'] = (gameStats[key]!['attempts'] as int) + 1;
        gameStats[key]!['totalScore'] = (gameStats[key]!['totalScore'] as int) + score;
        (gameStats[key]!['scores'] as List<int>).add(score);

        if (attempt.timestamp != null) {
          (gameStats[key]!['timestamps'] as List<String>).add(attempt.timestamp!);
        }

        if (score > (gameStats[key]!['bestScore'] as int)) {
          gameStats[key]!['bestScore'] = score;
        }
      }

      // Calculate average score for this game
      final scores = gameStats[key]!['scores'] as List<int>;
      if (scores.isNotEmpty) {
        gameStats[key]!['averageScore'] =
            scores.reduce((a, b) => a + b) / scores.length;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCorrect = widget.correctWords.length +
        widget.correctLetters.length +
        widget.correctSentences.length;
    final totalIncorrect = widget.incorrectWords.length +
        widget.incorrectLetters.length +
        widget.incorrectSentences.length;
    final total = totalCorrect + totalIncorrect;
    final accuracy = total > 0 ? (totalCorrect / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          "${widget.learnerName}'s Progress",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Enhanced Stats Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3498DB),
                            const Color(0xFF2980B9),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.learnerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@${widget.username}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getAccuracyColor(accuracy),
                            _getAccuracyColor(accuracy).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: _getAccuracyColor(accuracy).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "$accuracy%",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedStatCard(
                          "Total Attempts",
                          total.toString(),
                          const Color(0xFF3498DB),
                          Icons.assessment
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(
                          "Correct",
                          totalCorrect.toString(),
                          const Color(0xFF27AE60),
                          Icons.check_circle
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(
                          "Incorrect",
                          totalIncorrect.toString(),
                          const Color(0xFFE74C3C),
                          Icons.cancel
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Enhanced Tab Navigation
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3498DB),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF3498DB),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Words"),
                Tab(text: "Letters"),
                Tab(text: "Sentences"),
                Tab(text: "Games"),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Words Tab
                _buildTabContent([
                  _buildEnhancedSection("Correct Words", widget.correctWords, const Color(0xFF27AE60), false, false),
                  _buildEnhancedSection("Incorrect Words", widget.incorrectWords, const Color(0xFFE74C3C), false, true),
                ]),
                // Letters Tab
                _buildTabContent([
                  _buildEnhancedSection("Correct Letters", widget.correctLetters, const Color(0xFF27AE60), true, false),
                  _buildEnhancedSection("Incorrect Letters", widget.incorrectLetters, const Color(0xFFE74C3C), true, true),
                ]),
                // Sentences Tab
                _buildTabContent([
                  _buildEnhancedSection("Correct Sentences", widget.correctSentences, const Color(0xFF27AE60), false, false),
                  _buildEnhancedSection("Incorrect Sentences", widget.incorrectSentences, const Color(0xFFE74C3C), false, true),
                ]),
                // Enhanced Games Tab
                _buildEnhancedGameSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 80) return const Color(0xFF27AE60);
    if (accuracy >= 60) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }

  Widget _buildEnhancedStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildEnhancedSection(String title, List<dynamic> items, Color color, bool isLetter, bool showCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    showCorrect ? Icons.cancel : Icons.check_circle,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No ${title.toLowerCase()} recorded",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEnhancedItemsList(items, isLetter, showCorrect),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedItemsList(List<dynamic> items, bool isLetter, bool showCorrect) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        String? spoken;
        String? correct;

        // Handle different item types
        if (isLetter) {
          // For Letter objects
          spoken = item.spokenLetter ?? "";
          correct = item.correctLetter;
        } else if (item is Word) {
          // For Word objects
          spoken = item.spokenWord ?? "";
          correct = item.correctWord;
        } else if (item is Sentence) {
          // For Sentence objects
          spoken = item.spokenSentence ?? "";
          correct = item.correctSentence;
        } else {
          // Fallback - try to access properties dynamically
          try {
            spoken = item.spokenWord ?? item.spokenSentence ?? "";
            correct = item.correctWord ?? item.correctSentence;
          } catch (e) {
            spoken = "";
            correct = "Unknown";
          }
        }

        // Use correct value if spoken is empty
        spoken = (spoken == "") ? correct : spoken;

        return Container(
          margin: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: showCorrect
                        ? const Color(0xFFE74C3C).withOpacity(0.1)
                        : const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    showCorrect ? Icons.close : Icons.check,
                    color: showCorrect ? const Color(0xFFE74C3C) : const Color(0xFF27AE60),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: showCorrect
                      ? Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            spoken!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE74C3C),
                            ),
                          ),
                        ),
                      ),
                      if (correct != null && correct != spoken) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3498DB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              correct,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3498DB),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      correct!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildEnhancedGameSection() {
    if (widget.gameAttempts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    Icons.videogame_asset_outlined,
                    size: 48,
                    color: Colors.grey[400]
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "No game attempts recorded",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600]
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Start playing games to see your progress here",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500]
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group games by level
    Map<String, List<GameAttempt>> gamesByLevel = {};
    for (var gameAttempt in widget.gameAttempts) {
      final levelName = gameAttempt.levelName ?? 'Unknown Level';
      if (!gamesByLevel.containsKey(levelName)) {
        gamesByLevel[levelName] = [];
      }
      gamesByLevel[levelName]!.add(gameAttempt);
    }

    // Calculate overall stats
    int totalAttempts = widget.gameAttempts.fold(0, (sum, game) => sum + game.attempts.length);
    int totalGames = widget.gameAttempts.length;
    int bestOverallScore = widget.gameAttempts.fold(0, (best, game) {
      int gameBest = game.attempts.fold(0, (gameBest, attempt) =>
      attempt.score > gameBest ? attempt.score : gameBest);
      return gameBest > best ? gameBest : best;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Games Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3F51B5),
                  const Color(0xFF3F51B5).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3F51B5).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.videogame_asset,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Game Statistics",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$totalGames games • $totalAttempts attempts",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewStatCard(
                        "Levels",
                        gamesByLevel.length.toString(),
                        Icons.layers,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewStatCard(
                        "Games",
                        totalGames.toString(),
                        Icons.games,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewStatCard(
                        "Best Score",
                        bestOverallScore.toString(),
                        Icons.emoji_events,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Games by Level
          ...gamesByLevel.entries.map((levelEntry) {
            final levelName = levelEntry.key;
            final gamesInLevel = levelEntry.value;

            return _buildLevelSection(levelName, gamesInLevel);
          }).toList(),
        ],
      ),
    );
  }


  Widget _buildOverviewStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection(String levelName, List<GameAttempt> games) {
    // Calculate level stats
    int levelTotalAttempts = games.fold(0, (sum, game) => sum + game.attempts.length);
    double levelAverageScore = 0;
    int levelBestScore = 0;

    List<int> allScores = [];
    for (var game in games) {
      for (var attempt in game.attempts) {
        allScores.add(attempt.score);
        if (attempt.score > levelBestScore) {
          levelBestScore = attempt.score;
        }
      }
    }

    if (allScores.isNotEmpty) {
      levelAverageScore = allScores.reduce((a, b) => a + b) / allScores.length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF),
                  const Color(0xFF6C63FF).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.layers,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            levelName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${games.length} games • $levelTotalAttempts attempts",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLevelStatCard(
                        "Best Score",
                        levelBestScore.toString(),
                        Icons.emoji_events,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLevelStatCard(
                        "Average",
                        levelAverageScore.toStringAsFixed(1),
                        Icons.analytics,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLevelStatCard(
                        "Total",
                        levelTotalAttempts.toString(),
                        Icons.assessment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Games in this level
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: games.map((game) => _buildGameCard(game)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameAttempt game) {
    final gameName = game.gameName ?? 'Unknown Game';
    final attempts = game.attempts;
    final totalAttempts = attempts.length;

    // Calculate game stats
    int bestScore = attempts.fold(0, (best, attempt) =>
    attempt.score > best ? attempt.score : best);
    double averageScore = 0;
    if (attempts.isNotEmpty) {
      averageScore = attempts.fold(0, (sum, attempt) => sum + attempt.score) / attempts.length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.games,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$totalAttempts attempts",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "★ $bestScore",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Game Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGameStatItem(
                        "Best Score",
                        bestScore.toString(),
                        const Color(0xFFF39C12),
                        Icons.emoji_events,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGameStatItem(
                        "Average",
                        averageScore.toStringAsFixed(1),
                        const Color(0xFF3498DB),
                        Icons.analytics,
                      ),
                    ),
                  ],
                ),

                if (attempts.length > 1) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Recent Scores",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: attempts.take(8).map((attempt) {
                            final isPersonalBest = attempt.score == bestScore;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPersonalBest
                                    ? const Color(0xFFF39C12).withOpacity(0.1)
                                    : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isPersonalBest
                                      ? const Color(0xFFF39C12)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isPersonalBest) ...[
                                    Icon(
                                      Icons.star,
                                      size: 10,
                                      color: const Color(0xFFF39C12),
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    attempt.score.toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isPersonalBest
                                          ? const Color(0xFFF39C12)
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatItem(String label, String value, Color color, IconData icon) {
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
}