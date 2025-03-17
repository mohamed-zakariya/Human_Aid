import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';

class LearnerProfileWidget extends StatelessWidget {
  final Learner learner;

  // Dummy words learned by the user
  final List<String> wordsLearned = [
    "Apple", "Banana", "Carrot", "Dragonfruit", "Elephant",
    "Football", "Giraffe", "Hamburger", "Ice Cream", "Jellyfish",
    "Kangaroo", "Lemon", "Mountain", "Notebook", "Octopus"
  ];

  LearnerProfileWidget({super.key, required this.learner});

  @override
  Widget build(BuildContext context) {
    double progress = wordsLearned.length / 50.0; // Example dynamic progress

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 15,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(
                learner.gender == 'male'
                    ? "assets/images/boy.jpeg"
                    : "assets/images/girl.jpeg",
              ),
              radius: 50,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✍️ Handwritten Username Style
        Text(
          learner.name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          learner.username,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black38,
            fontStyle: FontStyle.italic
          ),
        ),

        // ✅ Stylish Words Learned Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Words Learned: ${wordsLearned.length}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // 📜 Additional Stats in Beautiful Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard("📜 Daily Quests Completed", 3),
            _buildStatCard("🏆 Rewards Quests Claimed", 5),
          ],
        ),

        const SizedBox(height: 20),

        // 📖 Learned Words Section
        _buildWordsLearnedSection(),
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
  // 📝 Learned Words List Section
  Widget _buildWordsLearnedSection() {
    return Container(
        decoration: const BoxDecoration(
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Learned Words:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250, // Set a fixed height to allow smooth scrolling
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: wordsLearned.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade50], // Subtle gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                          wordsLearned[index],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
