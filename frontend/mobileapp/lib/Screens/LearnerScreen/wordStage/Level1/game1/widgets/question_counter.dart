import 'package:flutter/material.dart';

class QuestionCounter extends StatelessWidget {
  final int current;
  final int total;

  const QuestionCounter({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(-2, -2), blurRadius: 6),
        ],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'السؤال ',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            TextSpan(
              text: '$current',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' / $total',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
