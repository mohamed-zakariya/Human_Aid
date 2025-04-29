import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isSubmitted;
  final VoidCallback onTap;

  const AnswerOption({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isSubmitted,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (!isSubmitted) {
      bgColor = isSelected ? const Color(0xFFADD8E6) : const Color(0xFF2D2D50);
    } else {
      if (isSelected && isCorrect) {
        bgColor = const Color(0xFFB6E2A1);
      } else if (isSelected && !isCorrect) {
        bgColor = const Color(0xFFF4A8A8);
      } else if (isCorrect) {
        bgColor = const Color(0xFFB6E2A1).withOpacity(0.5);
      } else {
        bgColor = const Color(0xFF2D2D50);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.right,
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: null, // Allow as many lines as needed
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
