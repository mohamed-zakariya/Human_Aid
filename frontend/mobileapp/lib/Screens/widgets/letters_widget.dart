import 'package:flutter/material.dart';

class LettersWidget extends StatelessWidget {
  final List<String> letters;

  const LettersWidget({
    Key? key,
    required this.letters,
  }) : super(key: key);

  Widget _buildLetterCard(String letter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: letters.map((letter) => _buildLetterCard(letter)).toList(),
    );
  }
}
