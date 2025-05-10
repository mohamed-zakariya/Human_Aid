import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LetterTile extends StatelessWidget {
  final String letter;

  const LetterTile({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF7F73FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF7F73FF).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF7F73FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F73FF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
