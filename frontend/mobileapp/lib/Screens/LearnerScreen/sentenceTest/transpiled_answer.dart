import 'package:flutter/material.dart';

class TranspiledAnswer extends StatelessWidget {
  final String correctAnswer;

  const TranspiledAnswer({
    required this.correctAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "🧠 Transpiled Answer: $correctAnswer",
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white70),
            onPressed: () {
              // Handle record button press here
              print("Record button pressed!");
            },
          ),
        ],
      ),
    );
  }
}
