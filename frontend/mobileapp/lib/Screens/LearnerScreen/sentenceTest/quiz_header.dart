import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final String question;
  final int index;
  final int total;

  const QuestionHeader({
    required this.question,
    required this.index,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/images/quiz_image.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(total, (i) {
            return CircleAvatar(
              radius: 15,
              backgroundColor: i == index ? Colors.pinkAccent : Colors.white24,
              child: Text(
                "${i + 1}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        // Updated Question Block
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D50), // Slightly lighter background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            question,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.6, // Line height
              fontWeight: FontWeight.w600,
              // fontFamily: 'OpenDyslexic' // If you want to use a dyslexic font
            ),
          ),
        ),

        const Text(
          "اختر إجابة واحدة.",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
