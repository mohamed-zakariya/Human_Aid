import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/dailyAttempts/learner_daily_attempts.dart';

class LearnerProgressDetailsPage extends StatefulWidget {
  final String learnerName;
  final String username;
  final List<Word> correctWords;
  final List<Word> incorrectWords;
  final List<Letter> correctLetters; // List of 'Letter' objects
  final List<Letter> incorrectLetters; // List of 'Letter' objects
  final List<Map<String, dynamic>> gameAttempts;

  const LearnerProgressDetailsPage({
    required this.learnerName,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.gameAttempts,
    super.key,
  });

  @override
  State<LearnerProgressDetailsPage> createState() => _LearnerProgressDetailsPageState();
}

class _LearnerProgressDetailsPageState extends State<LearnerProgressDetailsPage> {
  @override
  void initState() {
    super.initState();
    print(widget.correctLetters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text("${widget.learnerName}'s Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WORDS ---
              _buildSectionTitle("Correct Words", Colors.green),
              _buildGenericList(widget.correctWords, isLetter: false, showCorrect: false),

              const SizedBox(height: 20),
              _buildSectionTitle("Incorrect Words", Colors.red),
              _buildGenericList(widget.incorrectWords, isLetter: false, showCorrect: true),

              const SizedBox(height: 30),
              // --- LETTERS ---
              _buildSectionTitle("Correct Letters", Colors.green),
              _buildGenericList(widget.correctLetters, isLetter: true, showCorrect: false),

              const SizedBox(height: 20),
              _buildSectionTitle("Incorrect Letters", Colors.red),
              _buildGenericList(widget.incorrectLetters, isLetter: true, showCorrect: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericList(List<dynamic> items, {required bool isLetter, bool showCorrect = false}) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("No data recorded", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return Column(
      children: items.map((item) {
        print(item);
        String? spoken = isLetter ? item.spokenLetter ?? "" : item.spokenWord ?? "";
        String? correct = isLetter ? item.correctLetter : item.correctWord;
        print(correct);
        spoken = (spoken == "")? correct: spoken;
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
                Icon(showCorrect ? Icons.cancel : Icons.check_circle,
                    color: showCorrect ? Colors.red : Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: showCorrect
                      ? Row(
                    children: [
                      Text(
                        spoken!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                      if (correct != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_right_alt, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          correct,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ]
                    ],
                  )
                      : Text(
                    correct!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
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

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}