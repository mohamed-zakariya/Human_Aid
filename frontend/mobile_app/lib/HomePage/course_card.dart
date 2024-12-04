import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final int progress;
  final Color color;
  final String image;
  final VoidCallback onTap;  // Add the callback for handling taps

  const CourseCard({super.key, 
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
    required this.image,
    required this.onTap,  // Initialize the callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // Handle the tap action
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            color: color,
                            backgroundColor: color.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("$progress%"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: color.withOpacity(0.1),
              ),
              child: Image.asset(image, fit: BoxFit.contain), // Add your asset
            ),
          ],
        ),
      ),
    );
  }
}