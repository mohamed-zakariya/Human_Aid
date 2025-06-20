// letters_widget.dart
import 'package:flutter/material.dart';

class LettersWidget extends StatelessWidget {
  final List<String> letters;

  const LettersWidget({
    Key? key,
    required this.letters,
  }) : super(key: key);

  Widget _buildLetterCard(String letter, double cardSize, double fontSize) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive card size and font size
    final cardSize = (screenWidth * 0.12).clamp(40.0, 60.0); // 12% of screen width, clamped
    final fontSize = (screenWidth * 0.08).clamp(24.0, 36.0); // 8% of screen width, clamped
    
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: screenWidth * 0.02, // Responsive spacing
      runSpacing: screenHeight * 0.015, // Responsive run spacing
      alignment: WrapAlignment.center,
      children: letters.map((letter) => _buildLetterCard(letter, cardSize, fontSize)).toList(),
    );
  }
}
