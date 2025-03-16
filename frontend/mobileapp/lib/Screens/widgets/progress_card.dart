import 'package:flutter/material.dart';

/// A large "In Progress" card widget with progress indicator.
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
    return InkWell(
      onTap: () {
        // Handle card tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on $title')),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background / Illustrative image
            Align(
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Course info + progress
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    author,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  // Lesson count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$lessonCount Lessons',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: Colors.white38,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 149, 19, 144),
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
