import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';

import 'LearnerProfileWidget.dart';

class Learnerdata extends StatefulWidget {
  const Learnerdata({super.key, required this.learner});

  final Learner? learner;

  @override
  State<Learnerdata> createState() => _LearnerdataState();
}

class _LearnerdataState extends State<Learnerdata> {
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
          LearnerProfileWidget(learner: learner), // Profile Progress Widget
          const SizedBox(height: 20),
          // You can add more learner details here
                  ],
                )
          : const Center(
        child: Text("No learner data available."),
      ),
    );
  }
}
