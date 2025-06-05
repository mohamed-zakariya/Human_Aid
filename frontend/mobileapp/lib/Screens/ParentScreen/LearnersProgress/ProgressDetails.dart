import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentHome.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/models/parent.dart';
import '../../../generated/l10n.dart';
import 'LearnerCard.dart';
import '../../../models/dailyAttempts/learner_daily_attempts.dart';

class ProgressDetails extends StatefulWidget {
  const ProgressDetails({super.key, required this.parent});

  final Parent? parent;

  @override
  State<ProgressDetails> createState() => _ProgressDetailsState();
}

class _ProgressDetailsState extends State<ProgressDetails> {
  final List<String> days = List.generate(7, (index) {
    DateTime date = DateTime.now().subtract(Duration(days: index));
    return DateFormat("EEE d").format(date); // Example: "Mon 6"
  }).reversed.toList(); // Show oldest to newest

  Map<String, List<Map<String, dynamic>>> learnerProgress = {};
  late String selectedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = days.last; // Default: most recent day
    getData();
  }

  void getData() async {
    if (widget.parent == null) return;

    List<LearnerDailyAttempts>? attempts = await ParentService.getProgressWithDate(widget.parent!.id);

    if (attempts == null) {
      print("No progress data found.");
      return;
    }

    learnerProgress.clear();

    for (var entry in attempts) {
      DateTime parsedDate = DateTime.parse(entry.date);
      String formattedDate = DateFormat("EEE d").format(parsedDate);

      learnerProgress[formattedDate] = [];

      for (var user in entry.users) {
        learnerProgress[formattedDate]!.add({
          "user_id": user.userId,
          "username": user.username,
          "name": user.name,
          "correct_letters": user.correctLetters ?? [],
          "incorrect_letters": user.incorrectLetters ?? [],
          "correct_words": user.correctWords.map((w) => w.toMap()).toList() ?? [],
          "incorrect_words": user.incorrectWords.map((w) => w.toMap()).toList() ?? [],
          "correct_sentences": user.correctSentences ?? [],
          "incorrect_sentences": user.incorrectSentences ?? [],
          "game_attempts": user.gameAttempts.map((gameAttempt) => {
            "game_id": gameAttempt.gameId,
            "level_id": gameAttempt.levelId,
            "attempts": gameAttempt.attempts.map((a) => {
              "score": a.score,
            }).toList() ?? [],
          }).toList() ?? [],
          "words_read": (user.correctWords.length ?? 0) + (user.incorrectWords.length ?? 0),
          "correct_words_count": user.correctWords.length ?? 0,
          "incorrect_words_count": user.incorrectWords.length ?? 0,
          // "completed_daily_quest": user.completedDailyQuest ?? false,
          // "awards_taken": user.awardsTaken ?? false,
        });
      }
    }
    print(learnerProgress);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    List<Color> colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B9D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF6C63FF),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          S.of(context).learner_progress,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress Illustration
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        "assets/images/progress.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Track Learning Progress",
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Monitor daily learning activities",
                    style: TextStyle(
                      color: const Color(0xFF7F8C8D),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Modern Date Selector
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  String day = days[index];
                  bool isSelected = day == selectedDay;

                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: Container(
                      width: screenWidth / 5.5,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.split(' ')[0], // Day name (e.g., "Mon")
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF7F8C8D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day.split(' ')[1], // Day number (e.g., "6")
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2C3E50),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Progress Content
            Expanded(
              child: learnerProgress[selectedDay]?.isEmpty ?? true
                  ? _buildEmptyState()
                  : _buildProgressList(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7F8C8D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 40,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).no_progress_data,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No learning activities recorded for this day",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF7F8C8D).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList(List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: learnerProgress[selectedDay]!.length,
        itemBuilder: (context, index) {
          var progress = learnerProgress[selectedDay]![index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Childcard(
              title: "Progress Summary",
              learnerName: progress['name'] ?? "Unknown",
              username: progress['username'] ?? "Unknown",
              wordsRead: progress["words_read"] ?? 0,
              correctWords: progress["correct_words_count"] ?? 0,
              incorrectWords: progress["incorrect_words_count"] ?? 0,
              dailyQuestCompleted: progress["completed_daily_quest"] ?? false,
              awardReceived: progress["awards_taken"] ?? false,
              color: colors[index % colors.length],
              icon: (progress["awards_taken"] ?? false) ? Icons.emoji_events : Icons.cancel,

              correctWordList: (progress["correct_words"] ?? [])
                  .map<Word>((wordMap) => Word.fromJson(wordMap))
                  .toList(),

              incorrectWordList: (progress["incorrect_words"] ?? [])
                  .map<Word>((wordMap) => Word.fromJson(wordMap))
                  .toList(),
              correctLetters: List<Letter>.from(progress["correct_letters"] ?? []),
              incorrectLetters: List<Letter>.from(progress["incorrect_letters"] ?? []),
              correctSentences: List<Sentence>.from(progress["correct_letters"] ?? []),
              incorrectSentences: List<Sentence>.from(progress["incorrect_letters"] ?? []),
              gameAttempts: List<Map<String, dynamic>>.from(
                (progress['game_attempts'] ?? []).map((gameAttempt) => {
                  'game_id': gameAttempt['game_id'],
                  'level_id': gameAttempt['level_id'],
                  'attempts': List<int>.from(
                    (gameAttempt['attempts'] ?? []).map((a) => a['score']),
                  ),
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}