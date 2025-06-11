import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import 'package:mobileapp/models/overall_progress.dart';
import 'package:mobileapp/generated/l10n.dart';

import '../overallLearnerProgress/LearnerProfileWidget.dart';

class Learnerdata extends StatefulWidget {
  const Learnerdata({super.key, required this.learner, this.progress});

  final Learner? learner;
  final UserExerciseProgress? progress;

  @override
  State<Learnerdata> createState() => _LearnerdataState();
}

class _LearnerdataState extends State<Learnerdata> {
  @override
  void initState() {
    super.initState();
    print("here0");
  }

  @override
  Widget build(BuildContext context) {
    Learner? learner = widget.learner;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: learner != null
          ? SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(context),
            // Profile Content
            Expanded(
              child: LearnerProfileWidget(
                learner: learner,
                userProgress: widget.progress,
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Text(S.of(context).no_learner_data_available),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              S.of(context).learner_details,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Placeholder for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
