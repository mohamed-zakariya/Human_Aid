import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/Services/parent_service.dart';
import 'package:mobileapp/models/parent.dart';

import 'LearnerCard.dart';
import 'ParentMain.dart';

class ProgressDetails extends StatefulWidget {
  const ProgressDetails({super.key, required this.parent});

  final Parent? parent;

  @override
  State<ProgressDetails> createState() => _ProgressDetailsState();
}

class _ProgressDetailsState extends State<ProgressDetails> {
  final List<String> days = ["Mon 17", "Tue 18", "Wed 19", "Thu 20", "Fri 21"];

  Map<String, List<Map<String, dynamic>>> learnerProgress = {};
  String selectedDay = "Mon 17";

  @override
  void initState() {
    super.initState();
    getData();
    getDummyData();
  }

  void getData() async {
    await ParentService.getLearnerProgressbyDate("67c399d9230109f23da8e576");
  }

  void getDummyData() {
    learnerProgress = {
      "Mon 17": [
        {
          "words_read": 45,
          "correct_words": 38,
          "incorrect_words": 7,
          "completed_daily_quest": true,
          "awards_taken": true
        },
        {
          "words_read": 20,
          "correct_words": 15,
          "incorrect_words": 5,
          "completed_daily_quest": false,
          "awards_taken": false
        },
      ],
      "Tue 18": [
        {
          "words_read": 55,
          "correct_words": 45,
          "incorrect_words": 10,
          "completed_daily_quest": true,
          "awards_taken": true
        },
        {
          "words_read": 35,
          "correct_words": 30,
          "incorrect_words": 5,
          "completed_daily_quest": false,
          "awards_taken": false
        }
      ],
      "Wed 19": [
        {
          "words_read": 30,
          "correct_words": 20,
          "incorrect_words": 10,
          "completed_daily_quest": false,
          "awards_taken": false
        },
        {
          "words_read": 50,
          "correct_words": 45,
          "incorrect_words": 5,
          "completed_daily_quest": true,
          "awards_taken": true
        }
      ],
      "Thu 20": [
        {
          "words_read": 65,
          "correct_words": 60,
          "incorrect_words": 5,
          "completed_daily_quest": true,
          "awards_taken": true
        },
        {
          "words_read": 25,
          "correct_words": 20,
          "incorrect_words": 5,
          "completed_daily_quest": false,
          "awards_taken": false
        }
      ],
      "Fri 21": [
        {
          "words_read": 80,
          "correct_words": 75,
          "incorrect_words": 5,
          "completed_daily_quest": true,
          "awards_taken": true
        },
        {
          "words_read": 40,
          "correct_words": 35,
          "incorrect_words": 5,
          "completed_daily_quest": true,
          "awards_taken": false
        }
      ],
    };

    setState(() {}); // Refresh UI after setting dummy data
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    List<Color> colors = [
      // Colors.redAccent,
      // Colors.greenAccent,
      Colors.deepPurple,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.teal,
    ];

    Color getColorForIndex(int index) {
      return colors[index % colors.length];
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87, // Match with the illustration background
        elevation: 0, // Removes shadow for a seamless look
        title: Text("${widget.parent!.name} Dashboard",style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
        ),),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
                            //   mainAxisAlignment: MainAxisAlignment.center, // Evenly space elements
                            //   children: [
                            //     // const Expanded(
                            //     //   child: Text(
                            //     //     "Learners Progress",
                            //     //     style: const TextStyle(
                            //     //       color: Colors.black, // Changed to white for contrast
                            //     //       fontSize: 20,
                            //     //       fontWeight: FontWeight.bold,
                            //     //     ),
                            //     //   ),
                            //     // ),
                            //     const SizedBox(width: 10),
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(15), // Rounded image corners
                            //       child: Image.asset(
                            //         "assets/images/progress.png",
                            //         width: 180,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          const Text(
                            "Learners Progress",
                            style: const TextStyle(
                              color: Colors.black, // Changed to white for contrast
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15), // Rounded image corners
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
                                  onTap: () {
                                    setState(() {
                                      selectedDay = day;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width / 5.4,
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
                            child: ListView(
                              children: learnerProgress[selectedDay]?.map((progress) {
                                return Childcard(
                                  title: "Progress Summary",
                                  learnerName: "John Doe",
                                  username: "johndoe123",
                                  wordsRead: progress["words_read"],
                                  correctWords: progress["correct_words"],
                                  incorrectWords: progress["incorrect_words"],
                                  dailyQuestCompleted: progress["completed_daily_quest"],
                                  awardReceived: progress["awards_taken"],
                                  color: getColorForIndex(learnerProgress[selectedDay]!.indexOf(progress)),
                                  icon: progress["awards_taken"] ? Icons.emoji_events : Icons.cancel,
                                );
                              }).toList() ?? [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
