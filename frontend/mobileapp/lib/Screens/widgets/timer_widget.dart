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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: isRecording
                  ? (timerSeconds / maxRecordingSeconds)
                  : 0,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatTime(timerSeconds),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
