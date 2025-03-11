import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';

class Learnerprofile extends StatefulWidget {
  const Learnerprofile({super.key, required this.learner});

  final Learner? learner;

  @override
  State<Learnerprofile> createState() => _LearnerprofileState();
}

class _LearnerprofileState extends State<Learnerprofile> {


  @override
  Widget build(BuildContext context) {

    late Learner? learner = widget.learner;



    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Profile Picture with Background and Notification Dot
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepOrange[200], // Background color
                  borderRadius: BorderRadius.circular(25),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/boy2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // User Name and Email
          Text(
            learner!.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            learner.username,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // Stats Section
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("35+", "Quests", Icons.workspace_premium_outlined, Colors.green),
              _buildStatCard("50", "Following", Icons.people, Colors.blue),
              _buildStatCard("100", "Followers", Icons.group, Colors.purple),
            ],
          ),

          const SizedBox(height: 20),

          // Add Friends Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("Add Friends"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent[100],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Overview Section
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewCard("365", "Day Streak", Icons.local_fire_department, Colors.orange, true),
                    _buildOverviewCard("56776", "Total XP", Icons.flash_on, Colors.yellow, false),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewCard("Sapphire", "Current League", Icons.menu_book_outlined, Colors.black, true),
                    _buildOverviewCard("12", "Top 3 finishes", Icons.timer, Colors.black, true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// Function to create Stats Cards
Widget _buildStatCard(String value, String label, IconData icon, Color color) {
  return Container(
    width: 100,
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Colors.grey[100],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

// Function to create Overview Cards
Widget _buildOverviewCard(String value, String label, IconData icon, Color color, bool flag) {
  return Container(
    width: 150,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        flag == true? Icon(icon, color: color, size: 30)
            : const Image(image: AssetImage('assets/arcades/coins.png'), width: 30, height: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );
}

