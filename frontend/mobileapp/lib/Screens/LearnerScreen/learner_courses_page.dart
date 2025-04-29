import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/widgets/course_card.dart';
 // Make sure the path is correct relative to your file structure

class LearnerCoursesPage extends StatelessWidget {
  const LearnerCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated title
            Text(
              'اختر تمرين',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            // First Course Card
            CourseCard(
              imagePath: 'assets/images/image8.png',
              title: 'المستوى الأول',
              description: 'انطق الكلمات بشكل صحيح',
              progressValue: 0.2,
              progressColor: Colors.blue,
              progressText: '20%',
            ),

            SizedBox(height: 16),

            // Second Course Card
            CourseCard(
              imagePath: 'assets/images/image8.png',
              title: 'المستوى الثاني',
              description: 'تابع التمارين لتحسين النطق',
              progressValue: 0.5,
              progressColor: Colors.orange,
              progressText: '50%',
            ),
          ],
        ),
      ),
    );
  }
}
