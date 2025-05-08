import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SynonymSection extends StatelessWidget {
  final List<String> choices;
  final String? droppedSynonym;
  final bool synonymMatched;
  final Function(String) onDropped;
  final VoidCallback onNext;

  const SynonymSection({
    super.key,
    required this.choices,
    this.droppedSynonym,
    required this.synonymMatched,
    required this.onDropped,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7F73FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "اختر مرادف الكلمة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Synonym choices
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: choices.map((choice) {
              return Draggable<String>(
                data: choice,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4A7FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      choice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4A7FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    choice,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4A7FF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    choice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Drop area
          DragTarget<String>(
            onAccept: onDropped,
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: droppedSynonym != null
                      ? (synonymMatched ? Colors.green.shade100 : Colors.red.shade100)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: droppedSynonym != null
                        ? (synonymMatched ? Colors.green : Colors.red)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: droppedSynonym != null
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      droppedSynonym!,
                      style: TextStyle(
                        color: synonymMatched ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      synonymMatched ? Icons.check_circle : Icons.error,
                      color: synonymMatched ? Colors.green : Colors.red,
                    ),
                  ],
                )
                    : const Text(
                  "أسقط هنا",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Next button
          if (synonymMatched)
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7F73FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("التالي", style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


