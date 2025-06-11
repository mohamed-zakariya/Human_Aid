import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentHome.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/models/parent.dart';
import '../../../generated/l10n.dart';
import '../../../models/dailyAttempts/GameAttempt.dart';
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

    // Group data by date and user to avoid duplicates
    Map<String, Map<String, Map<String, dynamic>>> groupedData = {};

    for (var entry in attempts) {
      DateTime parsedDate = DateTime.parse(entry.date);
      String formattedDate = DateFormat("EEE d").format(parsedDate);

      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = {};
      }

      for (var user in entry.users) {
        String userKey = user.userId;

        if (!groupedData[formattedDate]!.containsKey(userKey)) {
          // Initialize user data
          groupedData[formattedDate]![userKey] = {
            "user_id": user.userId,
            "username": user.username,
            "name": user.name,
            "correct_letters": <Letter>[],
            "incorrect_letters": <Letter>[],
            "correct_words": <Word>[],
            "incorrect_words": <Word>[],
            "correct_sentences": <Sentence>[],
            "incorrect_sentences": <Sentence>[],
            "game_attempts": <GameAttempt>[],
          };
        }

        // Merge data for the same user on the same date
        var userData = groupedData[formattedDate]![userKey]!;
        userData["correct_letters"].addAll(user.correctLetters);
        userData["incorrect_letters"].addAll(user.incorrectLetters);
        userData["correct_words"].addAll(user.correctWords);
        userData["incorrect_words"].addAll(user.incorrectWords);
        userData["correct_sentences"].addAll(user.correctSentences);
        userData["incorrect_sentences"].addAll(user.incorrectSentences);
        userData["game_attempts"].addAll(user.gameAttempts);
      }
    }

    // Convert grouped data to final format and calculate totals
    for (var dateEntry in groupedData.entries) {
      String formattedDate = dateEntry.key;
      learnerProgress[formattedDate] = [];

      for (var userEntry in dateEntry.value.entries) {
        var userData = userEntry.value;

        // Calculate totals for all exercises
        final totalCorrect = (userData["correct_letters"] as List).length +
            (userData["correct_words"] as List).length +
            (userData["correct_sentences"] as List).length;

        final totalIncorrect = (userData["incorrect_letters"] as List).length +
            (userData["incorrect_words"] as List).length +
            (userData["incorrect_sentences"] as List).length;

        final totalAttempts = totalCorrect + totalIncorrect;
        final accuracy = totalAttempts > 0
            ? (totalCorrect / totalAttempts * 100).round()
            : 0;

        learnerProgress[formattedDate]!.add({
          "user_id": userData["user_id"],
          "username": userData["username"],
          "name": userData["name"],
          "correct_letters": userData["correct_letters"],
          "incorrect_letters": userData["incorrect_letters"],
          "correct_words": userData["correct_words"],
          "incorrect_words": userData["incorrect_words"],
          "correct_sentences": userData["correct_sentences"],
          "incorrect_sentences": userData["incorrect_sentences"],
          "game_attempts": userData["game_attempts"],
          "total_correct": totalCorrect,
          "total_incorrect": totalIncorrect,
          "total_attempts": totalAttempts,
          "accuracy": accuracy,
        });
      }
    }

    print("Processed learner progress: $learnerProgress");
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
      const Color(0xFF8B5CF6),
      const Color(0xFFFF8A65),
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
                      S.of(context).track_learning_progress,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                      S.of(context).monitor_daily_activities,
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
              S.of(context).no_learning_activities,
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
              title: S.of(context).progress_summary,
              learnerName: progress['name'] ?? "Unknown",
              username: progress['username'] ?? "Unknown",
              totalCorrect: progress["total_correct"] ?? 0,
              totalIncorrect: progress["total_incorrect"] ?? 0,
              accuracy: progress["accuracy"] ?? 0,
              dailyQuestCompleted: (progress["total_attempts"] ?? 0) >= 5, // Example condition
              awardReceived: (progress["accuracy"] ?? 0) >= 90, // Example condition
              color: colors[index % colors.length],
              icon: (progress["accuracy"] ?? 0) >= 80 ? Icons.emoji_events : Icons.school,
              correctWordList: List<Word>.from(progress["correct_words"] ?? []),
              incorrectWordList: List<Word>.from(progress["incorrect_words"] ?? []),
              correctLetters: List<Letter>.from(progress["correct_letters"] ?? []),
              incorrectLetters: List<Letter>.from(progress["incorrect_letters"] ?? []),
              correctSentences: List<Sentence>.from(progress["correct_sentences"] ?? []),
              incorrectSentences: List<Sentence>.from(progress["incorrect_sentences"] ?? []),
              gameAttempts: List<GameAttempt>.from(progress['game_attempts'] ?? []),
            ),
          );
        },
      ),
    );
  }
}