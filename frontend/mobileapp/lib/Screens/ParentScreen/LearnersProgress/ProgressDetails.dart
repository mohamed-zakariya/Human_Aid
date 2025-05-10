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
    List<Color> colors = [Colors.deepPurple, Colors.orangeAccent, Colors.blueAccent, Colors.teal];

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          S.of(context).dashboardTitle(widget.parent!.name),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              S.of(context).learner_progress,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                "assets/images/progress.png",
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Horizontal Date Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: days.map((day) {
                  bool isSelected = day == selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: Container(
                      width: screenWidth / 5.4,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color: isSelected ? Colors.orange : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              height: 5,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: learnerProgress[selectedDay]?.isEmpty ?? true
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).no_progress_data,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: learnerProgress[selectedDay]!.length,
                  itemBuilder: (context, index) {
                    var progress = learnerProgress[selectedDay]![index];
                    return Childcard(
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

                      correctWordList: List<Word>.from(
                        (progress["correct_words"] ?? []).map((word) => {"word": word}),
                      ),
                      incorrectWordList: List<Word>.from(
                        (progress["incorrect_words"] ?? []).map((word) => {"word": word}),
                      ),
                      correctLetters: List<Letter>.from(progress["correct_letters"] ?? []),
                      incorrectLetters: List<Letter>.from(progress["incorrect_letters"] ?? []),

                      gameAttempts: List<Map<String, dynamic>>.from(
                        (progress['game_attempts'] ?? []).map((gameAttempt) => {
                          'game_id': gameAttempt['game_id'],
                          'level_id': gameAttempt['level_id'],
                          'attempts': List<int>.from(
                            (gameAttempt['attempts'] ?? []).map((a) => a['score']),
                          ),
                        }),
                      ),
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
