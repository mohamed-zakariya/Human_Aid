import 'package:flutter/material.dart';
import 'course_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أهلا!",
                  style: TextStyle(color: Colors.purple, fontSize: 16),
                ),
                Text(
                  "إبراهيم مصطفى",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.notifications_outlined,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن المستوى",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  CourseCard(
                    title: "المستوى الأول",
                    description: "انطق الكلمات بشكل صحيح",
                    progress: 20,
                    color: Colors.purple,
                    image: "assets/images/level1.png.jpg",
                    onTap: () {
                      // Handle the tap action here, e.g., navigate to a new page
                      print("Level 1 tapped");
                    },
                  ),
                  const SizedBox(height: 16),
                  CourseCard(
                    title: "المستوى الثاني",
                    description: "تابع التمارين لتحسين النطق",
                    progress: 50,
                    color: Colors.orange,
                    image: "assets/images/level2.png.jpg",
                    onTap: () {
                      // Handle the tap action for Level 2
                      print("Level 2 tapped");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "الدورات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "ملفك",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "الإعدادات",
          ),
        ],
      ),
    );
  }
}