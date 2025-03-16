import 'package:flutter/material.dart';

/// The "Exercise Card" design for the Exercises section.
class ExerciseCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int lecturesCount;

  const ExerciseCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.lecturesCount,
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
      child: SizedBox(
        width: 160,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$lecturesCount % ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
