import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/NavBarLearner.dart';
import 'package:mobileapp/Services/learner_home_service.dart';
import 'package:mobileapp/models/learner.dart';
import '../widgets/exercise_card.dart';
import '../widgets/progress_card.dart';

class LearnerHomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  /// The [Learner] object passed in from a previous screen
  final Learner? learner;

  const LearnerHomeScreen({
    super.key,
    required this.onLocaleChange,
    required this.learner,
  });

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  /// Future holding the exercises data from the backend
  late Future<List<Map<String, dynamic>>> _exercisesFuture;

  @override
  void initState() {
    super.initState();

    // If we have a valid learner ID, fetch from the backend; else set empty
    if (widget.learner?.id != null && widget.learner!.id!.isNotEmpty) {
      _exercisesFuture =
          LearnerHomeService.fetchLearnerHomeData(widget.learner!.id!);
    } else {
      // Provide an initial value so it's never uninitialized
      _exercisesFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 238, 190, 198);

    return Scaffold(
      drawer: NavBarLearner(learner: widget.learner, onLocaleChange: widget.onLocaleChange,),
      appBar: AppBar(

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _exercisesFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // Data is loaded (or empty)
              final exercises = snapshot.data ?? [];

              // Extract those with "progress" field
              final inProgressExercises = exercises
                  .where((exercise) => exercise['progress'] != null)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ********************************
                  // Top Section (Header)
                  // ********************************
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile + Bell Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // User Avatar
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    'https://images.pexels.com/photos/5428148/pexels-photo-5428148.jpeg?auto=compress&cs=tinysrgb&w=600',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Greet by actual user name, or "User" if unknown
                                Text(
                                  'Hi, ${widget.learner?.name ?? 'User'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        const Text(
                          'My Courses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search Box
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search Course',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.mic, color: Colors.grey),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ********************************
                  // In Progress Section
                  // ********************************
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Text(
                      'In Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: inProgressExercises.isEmpty
                        ? const Center(child: Text('No in-progress exercises.'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: inProgressExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = inProgressExercises[index];
                              final title = exercise['name'] ?? 'Unknown';
                              final progress = exercise['progress'];
                              final score = progress?['score'] ?? 0;
                              final accuracy = (progress?['accuracyPercentage'] ?? 0.0).toDouble();

                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ProgressCard(
                                  title: title,
                                  author: '', // or any relevant string
                                  lessonCount: score, // using 'score' for demonstration
                                  backgroundColor: const Color(0xFFA8D1D1),
                                  imageUrl: 'https://drive.google.com/uc?export=view&id=15j_yeDnQ3RlSqWpBeHGXHSAOdQVA_d-h',
                                  progressValue: accuracy / 100, // Convert 0..100 to 0..1
                                ),
                              );
                            },
                          ),
                  ),

                  // ********************************
                  // Exercises Section
                  // ********************************
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: exercises.isEmpty
                        ? const Center(child: Text('No exercises.'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              final title = exercise['name'] ?? 'Unknown';
                              final progress = exercise['progress'];
                              final accuracy = (progress?['accuracyPercentage'] ?? 0.0).toDouble();

                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ExerciseCard(
                                  imageUrl: 'https://drive.google.com/uc?export=view&id=1IS7-4KoNMd5WgBGHdOvyhs2XWb4VA4RC',
                                  title: title,
                                  // We'll treat accuracy as lecturesCount for display
                                  lecturesCount: accuracy.toInt(),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: Implement onTap
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
