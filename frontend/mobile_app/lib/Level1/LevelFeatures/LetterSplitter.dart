import 'package:flutter/material.dart';


class LetterSplitter extends StatelessWidget {
  final String letter;
  final int stringLength; // Length of the entire string to adjust font size dynamically
  final double screenWidth;

  const LetterSplitter({
    super.key,
    required this.letter,
    required this.stringLength,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic font size based on string length
    double fontSize = (screenWidth / 12) / (stringLength > 0 ? stringLength / 2 : 1);

    return Container(
      width: screenWidth / 8, // Adjust width relative to screen size
      height: screenWidth / 10, // Adjust height relative to screen size
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5), // Uniform margin
      decoration: BoxDecoration(
        color: const Color(0xFFD3D3FF),
        borderRadius: BorderRadius.circular(6), // Rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Text(
        letter.replaceAll(' ', '-'),
        style: TextStyle(
          fontSize: fontSize.clamp(30.0, 50.0), // Clamp to a reasonable range
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "OpenDyslexic",
        ),
      ),
    );
  }
}



