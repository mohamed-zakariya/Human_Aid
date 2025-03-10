import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/LearnerRewards.dart';
import 'package:mobileapp/Screens/LearnerScreen/LearnerProfile.dart';
import 'package:mobileapp/Screens/LearnerScreen/NavBarLearner.dart';
import '../../models/learner.dart';

class LearnerMain extends StatefulWidget {
  const LearnerMain({super.key, this.learner, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;
  final Learner? learner;

  @override
  _LearnerMainState createState() => _LearnerMainState();
}

class _LearnerMainState extends State<LearnerMain> {
  int _selectedIndex = 0; // Track selected tab index

  // List of screens corresponding to bottom navigation items
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      LearnerRewards(learner: widget.learner), // Home content
      // LearnerCourses(learner: widget.learner), // Courses content
      LearnerRewards(learner: widget.learner), // Home content
      Learnerprofile(learner: widget.learner), // Profile content
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarLearner(learner: widget.learner, onLocaleChange: widget.onLocaleChange,),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStat(Icons.local_fire_department, "200"),
                _buildStat(Icons.military_tech, "1017"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.grey[900],
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex, // Set selected tab
          onTap: _onItemTapped, // Handle tab change
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
      ),
      body: _screens[_selectedIndex], // Display the selected screen
    );
  }
}

Widget _buildStat(IconData icon, String value) {
  return Row(
    children: [
      Icon(icon, color: Colors.orange),
      const SizedBox(width: 4),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );
}
