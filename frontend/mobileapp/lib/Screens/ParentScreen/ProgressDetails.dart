import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ChildCard.dart';
import 'ParentHome.dart';

class ProgressDetails extends StatefulWidget {
  const ProgressDetails({super.key});

  @override
  State<ProgressDetails> createState() => _ProgressDetailsState();
}

class _ProgressDetailsState extends State<ProgressDetails> {

  final List<String> days = ["Mon 17", "Tue 18", "Wed 19", "Thu 20", "Fri 21"];

  // Events mapped by day
  final Map<String, List<Map<String, dynamic>>> events = {
    "Mon 17": [
      {"title": "Doctor Appointment", "time": "10:00 AM", "color": Colors.blue, "icon": Icons.local_hospital},
      {"title": "Team Meeting", "time": "3:00 PM", "color": Colors.green, "icon": Icons.work},
    ],
    "Tue 18": [
      {"title": "Library Visit", "time": "2:00 PM", "color": Colors.orange, "icon": Icons.book},
      {"title": "Gym Session", "time": "6:00 PM", "color": Colors.red, "icon": Icons.fitness_center},
    ],
    "Wed 19": [
      {"title": "Marta's Birthday", "time": "5:00 PM", "color": Colors.purple, "icon": Icons.cake},
    ],
    "Thu 20": [
      {"title": "Project Deadline", "time": "11:59 PM", "color": Colors.red, "icon": Icons.warning},
      {"title": "Dinner with Family", "time": "7:00 PM", "color": Colors.blueGrey, "icon": Icons.restaurant},
    ],
    "Fri 21": [
      {"title": "Movie Night", "time": "8:00 PM", "color": Colors.teal, "icon": Icons.movie},
    ],
  };

  // Default selected day
  String selectedDay = "Mon 17";



  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar with Transparent Background

                // Bottom Container with Calendar & Events
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Calendar Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: days.map((day) {
                              bool isSelected = day == selectedDay;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDay = day;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          color: isSelected ? Colors.orange : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        height: 5,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Events List
                          Expanded(
                            child: ListView(
                              children: events[selectedDay]!.map((event) {
                                return Childcard(
                                  title: event["title"],
                                  time: event["time"],
                                  color: event["color"],
                                  icon: event["icon"],
                                );
                              }).toList(),
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
