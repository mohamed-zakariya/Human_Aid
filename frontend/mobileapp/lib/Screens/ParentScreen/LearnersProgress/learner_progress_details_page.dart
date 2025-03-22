import 'package:flutter/material.dart';

class LearnerProgressDetailsPage extends StatelessWidget {
  final String learnerName;
  final String username;
  final List<Map<String, String>> correctWords;
  final List<Map<String, String>> incorrectWords;

  const LearnerProgressDetailsPage({
    super.key,
    required this.learnerName,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text("$learnerName's Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Correct Words", Colors.green),
              _buildWordList(correctWords, Icons.check_circle, Colors.green, showCorrect: false),

              const SizedBox(height: 20),

              _buildSectionTitle("Incorrect Words", Colors.red),
              _buildWordList(incorrectWords, Icons.cancel, Colors.red, showCorrect: true),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Builds Section Title with Color
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  /// 🔹 Builds List of Words (Correct & Incorrect) with enhanced card design
  Widget _buildWordList(List<Map<String, String>> words, IconData icon, Color iconColor, {bool showCorrect = false}) {
    if (words.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("No words recorded", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return Column(
      children: words.map((word) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black87, Colors.black54],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: showCorrect
                      ? Row(
                    children: [
                      Text(
                        word["spoken_word"] ?? "",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red),
                      ),
                      if (word["correct_word"] != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_right_alt, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          word["correct_word"]!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ],
                  )
                      : Text(
                    word["spoken_word"] ?? "",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
