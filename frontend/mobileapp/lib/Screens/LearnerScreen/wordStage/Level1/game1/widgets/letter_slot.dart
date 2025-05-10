// Widgets

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LetterSlot extends StatelessWidget {
  final String? letter;
  final Function(String) onAccept;

  const LetterSlot({
    super.key,
    this.letter,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: (data) {
        // Play drop sound when letter is dropped
        final player = AudioPlayer();
        player.setSource(AssetSource('sounds/drop.mp3'));
        player.resume();

        onAccept(data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: letter != null ? const Color(0xFF7F73FF) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            boxShadow: letter != null
                ? [
              BoxShadow(
                color: const Color(0xFF7F73FF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: letter != null
              ? Text(
            letter!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        );
      },
    );
  }
}
