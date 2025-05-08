import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';

import '../../../generated/l10n.dart';
import '../../../global/fns.dart';
import 'learner_progress_details_page.dart';

class Childcard extends StatefulWidget {
  final String title;
  final String learnerName;
  final String username;
  final int wordsRead;
  final int correctWords;
  final int incorrectWords;
  final bool dailyQuestCompleted;
  final bool awardReceived;
  final Color color;
  final IconData icon;
  final List<Word> correctWordList; // New: List of correct words
  final List<Word> incorrectWordList; // New: List of incorrect words
  final List<Letter> correctLetters;
  final List<Letter> incorrectLetters;
  final List<Map<String, dynamic>> gameAttempts;

  const Childcard({
    super.key,
    required this.title,
    required this.learnerName,
    required this.username,
    required this.wordsRead,
    required this.correctWords,
    required this.incorrectWords,
    required this.dailyQuestCompleted,
    required this.awardReceived,
    required this.color,
    required this.icon,
    required this.correctWordList,
    required this.incorrectWordList,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.gameAttempts,
  });

  @override
  State<Childcard> createState() => _ChildcardState();
}

class _ChildcardState extends State<Childcard> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.correctLetters);
    print(widget.incorrectLetters);
    print(widget.correctWordList);
    print(widget.incorrectWordList);


  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Icon
            Row(
              children: [
                Icon(widget.icon, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Learner's Name and Username
            Text(
              "Learner: ${widget.learnerName}",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Username: @${widget.username}",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 10),


            const SizedBox(height: 8),

            // Correct and Incorrect Words with Icons
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                const SizedBox(width: 5),
                Text(
                  "Correct: ${widget.correctWordList.length + widget.correctLetters.length}",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
                const SizedBox(width: 5),
                Text(
                  "Incorrect: ${widget.incorrectWordList.length + widget.incorrectLetters.length}",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Daily Quest Completed
            Row(
              children: [
                Icon(
                  widget.dailyQuestCompleted ? Icons.check_circle : Icons.cancel,
                  color: widget.dailyQuestCompleted ? Colors.greenAccent : Colors.redAccent,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.dailyQuestCompleted ? "Daily Quest Completed" : "Daily Quest Incomplete",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),

            // Award Received
            Row(
              children: [
                Icon(
                  widget.awardReceived ? Icons.emoji_events : Icons.lock,
                  color: widget.awardReceived ? Colors.yellow : Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.awardReceived ? "Award Received" : "No Award",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Details Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    createRouteParentLearnerProgress(LearnerProgressDetailsPage(
                      learnerName: widget.learnerName,
                      username: widget.username,
                      correctWords: widget.correctWordList,
                      incorrectWords: widget.incorrectWordList,
                      correctLetters: widget.correctLetters,
                      incorrectLetters: widget.incorrectLetters,
                      // correctSentences: correctSentences,
                      // incorrectSentences: incorrectSentences,
                      gameAttempts: widget.gameAttempts,
                    )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text(S.of(context).view_details),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

