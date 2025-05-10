import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import 'package:mobileapp/models/overall_progress.dart';

import 'LearnerProfileWidget.dart';

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
    // TODO: implement initState
    super.initState();
    print("here1");
  }
  @override
  Widget build(BuildContext context) {
    Learner? learner = widget.learner;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Learner Details"),
        centerTitle: true,
      ),
      body: learner != null
          ? Column(
        children: [
          const SizedBox(height: 20),
          if (widget.progress != null) // ✅ Pass only if progress is not null
            LearnerProfileWidget(
              learner: learner,
              userProgress: widget.progress!,
            )
          else
            LearnerProfileWidget(learner: learner), // ✅ Don't pass progress if null
          const SizedBox(height: 20),
        ],
      )
          : const Center(
        child: Text("No learner data available."),
      ),
    );
  }
}
