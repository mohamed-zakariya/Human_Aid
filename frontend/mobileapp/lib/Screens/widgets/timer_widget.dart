import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final bool isRecording;
  final int timerSeconds;
  final int maxRecordingSeconds;
  final String Function(int) formatTime;

    const TimerWidget({
    Key? key,
    required this.isRecording,
    required this.timerSeconds,
    required this.maxRecordingSeconds,
    required this.formatTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Responsive padding
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: screenHeight * 0.01, // Responsive progress bar height
              child: LinearProgressIndicator(
                value: isRecording
                    ? (timerSeconds / maxRecordingSeconds)
                    : 0,
                backgroundColor: Colors.white,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            formatTime(timerSeconds),
            style: TextStyle(
              fontSize: (screenWidth * 0.045).clamp(16.0, 20.0), // Responsive font size
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
