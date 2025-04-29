import 'package:flutter/material.dart';
import '../../models/level.dart';
import '../../generated/l10n.dart';

class LevelCard extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;
  final bool isArabic;
  final int colorIndex;

  const LevelCard({
    Key? key,
    required this.level,
    required this.onTap,
    required this.isArabic,
    required this.colorIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a list of gradient colors for the cards
    final List<List<Color>> gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF584DFF)], // Purple
      [const Color(0xFF4A80F0), const Color(0xFF1A56F0)], // Blue
      [const Color(0xFF3AA8A8), const Color(0xFF2A8A8A)], // Teal
      [const Color(0xFFFF6C8F), const Color(0xFFFF4A73)], // Pink
      [const Color(0xFFFFAA33), const Color(0xFFFF8800)], // Orange
    ];

    // Get the gradient for this card based on the color index
    final List<Color> cardGradient = gradients[colorIndex % gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardGradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Level number circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        level.levelNumber.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Level name and game count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? level.arabicName : level.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${level.games.length} ${S.of(context).games}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Completion indicator bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // This would show completion percentage
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3, // Example: 30% completed
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}