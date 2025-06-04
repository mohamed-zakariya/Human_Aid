import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import '../../../models/overall_progress.dart';

class LearnerProfileWidget extends StatefulWidget {
  final Learner learner;
  final UserExerciseProgress? userProgress;

  LearnerProfileWidget({super.key, required this.learner, this.userProgress});

  @override
  State<LearnerProfileWidget> createState() => _LearnerProfileWidgetState();
}


class _LearnerProfileWidgetState extends State<LearnerProfileWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.userProgress?.overallStats.combinedAccuracy ?? 0.0;

    List<String> learnedWords = widget.userProgress?.progressByExercise
        .expand((e) => e.stats.totalCorrect.items)
        .toList() ??
        [];

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: progress > 0 ? progress : 0.0, // ✅ Prevent null values
                strokeWidth: 15,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(
                widget.learner.gender == 'male'
                    ? "assets/images/boy.jpeg"
                    : "assets/images/girl.jpeg",
              ),
              radius: 50,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Learner name and username
        Text(
          widget.learner.name,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Text(
          widget.learner.username,
          style: const TextStyle(fontSize: 20, color: Colors.black38, fontStyle: FontStyle.italic),
        ),

        // Words Learned Section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.userProgress != null
                ? "Words Learned: ${learnedWords.length}"
                : "No progress data available",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),

        const SizedBox(height: 15),

        // Stats section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard("📜 Daily Quests Completed", 5),
            _buildStatCard("🏆 Rewards Claimed", 3),
          ],
        ),

        const SizedBox(height: 20),

        // Learned Words Section
        if (learnedWords.isNotEmpty)
          _buildWordsLearnedSection(learnedWords)
        else
        // ... show "No learned words yet"
          const Column(
            children: [
              Icon(Icons.menu_book, size: 40, color: Colors.grey), // Book icon 📖
              SizedBox(height: 8),
              Text(
                "No learnt words yet.",
                style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ],
          ),

      ],
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordsLearnedSection(List<String> words) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Learned Words:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: words.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade100, Colors.green.shade50]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        words[index],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
