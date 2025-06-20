import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';
import '../exercises_levels_screen.dart';

// Import the generated localization class
import '../../generated/l10n.dart';

class ExerciseCard extends StatelessWidget {
  final String exerciseId;
  final String imageUrl;
  final String title;
  final String arabicTitle;
  final int lecturesCount;
  final Learner learner;
  final Color color;
  final String exerciseImageUrl;
  final VoidCallback? onTap;

  const ExerciseCard({
    Key? key,
    required this.exerciseId,
    required this.imageUrl,
    required this.title,
    this.arabicTitle = '', // Default empty string for backward compatibility
    required this.lecturesCount,
    required this.learner,
    required this.color,
    required this.exerciseImageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String progressString = lecturesCount.toString();
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      width: double.infinity,
                      color: color.withOpacity(0.2),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: color,
                        size: 40,
                      ),
                    ),
                  ),
                  if (lecturesCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          S.of(context).exerciseProgressPercent(progressString),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Linear progress
                  LinearProgressIndicator(
                    value: lecturesCount / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),

                  // Row with "Progress" label and percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).exerciseProgressLabel,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        S.of(context).exerciseProgressPercent(progressString),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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