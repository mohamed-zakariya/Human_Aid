import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/NavBarLearner.dart';
import 'package:mobileapp/Services/learner_home_service.dart';
import 'package:mobileapp/models/learner.dart';
import '../widgets/exercise_card.dart';
import '../widgets/progress_card.dart';

// Import your generated localization file
import '../../generated/l10n.dart';

class LearnerHomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Learner? learner;

  const LearnerHomeScreen({
    Key? key,
    required this.onLocaleChange,
    required this.learner,
  }) : super(key: key);

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  final Color _primaryColor = const Color(0xFF6C63FF); // Primary color
  final Color _secondaryColor = const Color(0xFFF8F9FA); // Light background color

  @override
  void initState() {
    super.initState();
    if (widget.learner?.id != null && widget.learner!.id!.isNotEmpty) {
      _exercisesFuture = LearnerHomeService.fetchLearnerHomeData(widget.learner!.id!);
    } else {
      _exercisesFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarLearner(
        learner: widget.learner,
        onLocaleChange: widget.onLocaleChange,
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).helloLabel, // Localized "Hello,"
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.learner?.name ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: const NetworkImage(
                            'https://images.pexels.com/photos/5428148/pexels-photo-5428148.jpeg',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: S.of(context).searchCoursesHint, // Localized "Search courses..."
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Container(
                color: _secondaryColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _exercisesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      final exercises = snapshot.data ?? [];
                      final inProgressExercises = exercises
                          .where((exercise) => exercise['progress'] != null)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // In Progress Section
                          if (inProgressExercises.isNotEmpty) ...[
                            // "Continue Learning"
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                              child: Text(
                                S.of(context).continueLearning,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(left: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: inProgressExercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = inProgressExercises[index];
                                  final title = exercise['name'] ?? 'Unknown';
                                  final progress = exercise['progress'];
                                  final score = progress?['score'] ?? 0;
                                  final accuracy = (progress?['accuracyPercentage'] ?? 0.0).toDouble();
                                  final colors = [
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF4A80F0),
                                    const Color(0xFF3AA8A8),
                                  ];

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: ProgressCard(
                                      title: title,
                                      author: 'Exercise Description',
                                      lessonCount: score,
                                      backgroundColor: colors[index % colors.length],
                                      imageUrl: 'https://drive.google.com/uc?export=download&id=1xy93PTPBA7SShsbbxS56bBlEPuKav85p',
                                      progressValue: accuracy / 100,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // All Exercises Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // "Available Exercises"
                                Text(
                                  S.of(context).availableExercises,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    S.of(context).seeAll,
                                    style: TextStyle(color: _primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (exercises.isNotEmpty) ...[
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = exercises[index];
                                final title = exercise['name'] ?? 'Unknown';
                                final progress = exercise['progress'];
                                final accuracy = (progress?['accuracyPercentage'] ?? 0.0).toDouble();

                                return ExerciseCard(
                                  imageUrl: 'https://drive.google.com/uc?export=view&id=1IS7-4KoNMd5WgBGHdOvyhs2XWb4VA4RC',
                                  title: title,
                                  lecturesCount: accuracy.toInt(),
                                  learner: widget.learner!,
                                  color: _primaryColor,
                                );
                              },
                            ),
                          ] else ...[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  S.of(context).noExercisesAvailable,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            // Handle navigation
          },
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: S.of(context).bottomNavHome,       // Localized "Home"
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: S.of(context).bottomNavCourses,    // Localized "Courses"
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: S.of(context).bottomNavProfile,    // Localized "Profile"
            ),
          ],
        ),
      ),
    );
  }
}
