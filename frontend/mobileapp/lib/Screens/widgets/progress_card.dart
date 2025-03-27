import 'package:flutter/material.dart';
// Import your generated localization file
import '../../generated/l10n.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String author;
  final int lessonCount;
  final double progressValue;
  final Color backgroundColor;
  final String imageUrl;

  const ProgressCard({
    Key? key,
    required this.title,
    required this.author,
    required this.lessonCount,
    required this.backgroundColor,
    required this.imageUrl,
    required this.progressValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int percentCompleted = (progressValue * 100).toInt();

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern or decorative element
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
              child: Opacity(
                opacity: 1,
                child: Image.network(
                  imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Author
                Text(
                  author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                // Progress indicator with percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Use localized string for progress
                        Text(
                          S.of(context).progressCompleted('$percentCompleted'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Use localized string for points
                        Text(
                          S.of(context).progressPoints('$lessonCount'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
