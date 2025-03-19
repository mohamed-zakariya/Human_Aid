import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/models/parent.dart';
import '../../../generated/l10n.dart';
import '../../../models/learner_daily_attempts.dart';
import 'LearnerCard.dart';

class ProgressDetails extends StatefulWidget {
  const ProgressDetails({super.key, required this.parent});

  final Parent? parent;

  @override
  State<ProgressDetails> createState() => _ProgressDetailsState();
}

class _ProgressDetailsState extends State<ProgressDetails> {
  final List<String> days = List.generate(5, (index) {
    DateTime date = DateTime.now().subtract(Duration(days: index));
    return DateFormat("EEE d").format(date); // Example: "Mon 17"
  }).reversed.toList();

  Map<String, List<Map<String, dynamic>>> learnerProgress = {};
  late String selectedDay;
  List<Map<String, dynamic>> learnerProgressData = [];

  @override
  void initState() {
    super.initState();
    selectedDay = days.last; // Set default to most recent day
    getData();
    getDummyData();
  }

  void getData() async {
    if (widget.parent == null) return; // Ensure parent is not null
    List<LearnerDailyAttempts>? attempts = await ParentService.getProgressWithDate(widget.parent!.id);
    print(attempts);
  }

  void getDummyData() {
    learnerProgressData = [
      {
        "date": "2025-03-15",
        "users": [
          {
            "user_id": "67c84373e6128ad8a1e98bd9",
            "name": "Joe",
            "username": "joe3mhima",
            "correct_words": [
              {"word_id": "67c4d4b8e1b54f012e19bf8a", "spoken_word": "تفاحة"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
            ],
            "incorrect_words": [
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "تفاحة"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
            ]
          }
        ]
      },
      {
        "date": "2025-03-17",
        "users": [
          {
            "user_id": "67c84373e6128ad8a1e98bd9",
            "name": "Mohamed",
            "username": "mhdzikoo",
            "correct_words": [],
            "incorrect_words": [
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
            ]
          }
        ]
      },
      {
        "date": "2025-03-16",
        "users": [
          {
            "user_id": "67c84373e6128ad8a1e98bd9",
            "name": "ibrahim",
            "username": "hima",
            "correct_words": [
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
              {"word_id": "67c4d4b8e1b54f012e19bf85", "spoken_word": "مدرسه"},
              {"word_id": "67c4d4b8e1b54f012e19bf91", "spoken_word": "متقار"},
            ],
            "incorrect_words": []
          }
        ]
      }
    ];

    learnerProgress.clear();
    for (var entry in learnerProgressData) {
      DateTime parsedDate = DateTime.parse(entry["date"]);
      String formattedDate = DateFormat("EEE d").format(parsedDate);

      for (var user in entry['users']) {
        int wordsRead = user['correct_words'].length + user['incorrect_words'].length;
        int correctWords = user['correct_words'].length;
        int incorrectWords = user['incorrect_words'].length;

        if (!learnerProgress.containsKey(formattedDate)) {
          learnerProgress[formattedDate] = [];
        }

        learnerProgress[formattedDate]!.add({
          "name": user["name"],
          "username": user["username"],
          "words_read": wordsRead,
          "correct_words": correctWords,
          "incorrect_words": incorrectWords,
          "correct_words_list": List<Map<String, String>>.from(user['correct_words'].map((word) => {
            "word_id": word["word_id"].toString(),
            "spoken_word": word["spoken_word"].toString()
          })),
          "incorrect_words_list": List<Map<String, String>>.from(user['incorrect_words'].map((word) => {
            "word_id": word["word_id"].toString(),
            "spoken_word": word["spoken_word"].toString()
          })),
          "completed_daily_quest": true,
          "awards_taken": true
        });
      }
    }


    print(learnerProgress);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    List<Color> colors = [Colors.deepPurple, Colors.orangeAccent, Colors.blueAccent, Colors.teal];

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          "${widget.parent!.name} ${S.of(context).dashboard_title}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
             Text(
              S.of(context).learner_progress,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                "assets/images/progress.png",
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: days.map((day) {
                  bool isSelected = day == selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: Container(
                      width: screenWidth / 5.4,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color: isSelected ? Colors.orange : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              height: 5,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: learnerProgress[selectedDay]?.isEmpty ?? true
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bar_chart,  // You can change this to Icons.insert_chart or any relevant icon
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).no_progress_data,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ) : ListView.builder(
                itemCount: learnerProgress[selectedDay]!.length,
                itemBuilder: (context, index) {
                  var progress = learnerProgress[selectedDay]![index];

                  return Childcard(
                    title: "Progress Summary",
                    learnerName: progress['name'],
                    username: progress['username'],
                    wordsRead: progress["words_read"] ?? 0,
                    correctWords: progress["correct_words"] ?? 0,
                    incorrectWords: progress["incorrect_words"] ?? 0,
                    dailyQuestCompleted: progress["completed_daily_quest"] ?? false,
                    awardReceived: progress["awards_taken"] ?? false,
                    color: colors[index % colors.length],
                    icon: (progress["awards_taken"] ?? false) ? Icons.emoji_events : Icons.cancel,
                    correctWordList: progress["correct_words_list"],
                    incorrectWordList: progress["incorrect_words_list"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
