// feedback_widget.dart
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

class FeedbackWidget extends StatelessWidget {
  final bool? isCorrect;
  final String feedbackMessage;
  final bool isProcessing;

  const FeedbackWidget({
    Key? key,
    required this.isCorrect,
    required this.feedbackMessage,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isProcessing) {
      return _buildProcessingIndicator(context);
    }

    if (feedbackMessage.isNotEmpty) {
      return _buildFeedbackMessage(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildProcessingIndicator(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: screenWidth * 0.05, // Responsive size
            height: screenWidth * 0.05,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            S.of(context).feedbackWidgetAnalyzing,
            style: TextStyle(
              fontSize: (screenWidth * 0.04).clamp(14.0, 18.0), // Responsive font size
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final Color primaryColor = isCorrect == true
        ? Colors.green
        : isCorrect == false
            ? Colors.red
            : Colors.blueGrey;

    final IconData icon = isCorrect == true
        ? Icons.check_circle_rounded
        : isCorrect == false
            ? Icons.error_rounded
            : Icons.info_rounded;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Container(
        key: ValueKey(feedbackMessage),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.017, 
          horizontal: screenWidth * 0.045
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: screenWidth * 0.07, // Responsive icon size
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                feedbackMessage,
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0), // Responsive font size
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
