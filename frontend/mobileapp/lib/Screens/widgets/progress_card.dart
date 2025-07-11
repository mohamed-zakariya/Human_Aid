import 'package:flutter/material.dart';
// Import your generated localization file
import '../../generated/l10n.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String description;
  final int lessonCount;
  final double progressValue;
  final Color backgroundColor;
  final String imageUrl;

  const ProgressCard({
    super.key,
    required this.title,
    required this.description,
    required this.lessonCount,
    required this.backgroundColor,
    required this.imageUrl,
    required this.progressValue,
  });

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
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ULTIMATE SOLUTION: Force identical visual appearance
          Positioned(
            bottom: -10, // Slightly adjust position
            right: -10,
            child: Container(
              width: 130, // Make container slightly bigger
              height: 130,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
                child: FittedBox(
                  fit: BoxFit.cover, // This ensures consistent sizing
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 200, // Force a consistent base size
                    height: 200,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // ALTERNATIVE SOLUTION 2: Using AspectRatio widget
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: ClipRRect(
          //     borderRadius: const BorderRadius.only(
          //       bottomRight: Radius.circular(16),
          //     ),
          //     child: SizedBox(
          //       width: 120,
          //       height: 120,
          //       child: AspectRatio(
          //         aspectRatio: 1.0, // Square aspect ratio
          //         child: Image.network(
          //           imageUrl,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // ALTERNATIVE SOLUTION 3: Using FittedBox for scaling
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: ClipRRect(
          //     borderRadius: const BorderRadius.only(
          //       bottomRight: Radius.circular(16),
          //     ),
          //     child: SizedBox(
          //       width: 120,
          //       height: 120,
          //       child: FittedBox(
          //         fit: BoxFit.cover,
          //         child: Image.network(
          //           imageUrl,
          //           errorBuilder: (context, error, stackTrace) {
          //             return Container(
          //               width: 120,
          //               height: 120,
          //               color: Colors.grey.withOpacity(0.3),
          //               child: const Icon(Icons.image_not_supported),
          //             );
          //           },
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

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

                // Description
                Text(
                  description,
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