// lib/Screens/LearnerScreen/learner_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:mobileapp/Services/learner_home_service.dart';
import 'package:mobileapp/models/learner.dart';
import '../widgets/exercise_card.dart';
import '../widgets/progress_card.dart';
import '../../generated/l10n.dart';

class LearnerDashboardPage extends StatefulWidget {
  final Learner? learner;
  final Function(Locale) onLocaleChange;
  final void Function(int) onSelectPage;

  const LearnerDashboardPage({
    Key? key,
    required this.learner,
    required this.onLocaleChange,
    required this.onSelectPage,
  }) : super(key: key);

  @override
  State<LearnerDashboardPage> createState() => _LearnerDashboardPageState();


}

class _LearnerDashboardPageState extends State<LearnerDashboardPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<List<Map<String, dynamic>>>? _exercisesFuture;
  bool _hasLoadedData = false;

  final Color _primaryColor = const Color(0xFF6C63FF);
  final Color _secondaryColor = const Color(0xFFF8F9FA);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData &&
        widget.learner?.id != null &&
        widget.learner!.id!.isNotEmpty) {
      _exercisesFuture =
          LearnerHomeService.fetchLearnerHomeData(widget.learner!.id!);
      _hasLoadedData = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SafeArea(
      child: Column(
        children: [
          /* ------------- header with search ----------------- */
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
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: S.of(context).searchCoursesHint,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          /* ------------- body ----------------- */
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
                        /* ----- continue learning carousel ----- */
                        if (inProgressExercises.isNotEmpty) ...[
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
                                final title = isArabic
                                    ? exercise['arabic_name']
                                    : exercise['name'];
                                final desc = isArabic
                                    ? exercise['arabic_description']
                                    : exercise['english_description'];
                                final progress = exercise['progress'];
                                final score = progress?['score'] ?? 0;
                                final accuracy =
                                    (progress?['progressPercentage'] ?? 0.0)
                                        .toDouble();

                                final colors = [
                                  const Color(0xFF6C63FF),
                                  const Color(0xFF4A80F0),
                                  const Color(0xFF3AA8A8),
                                ];

                                // Use progress_imageUrl from API if available
                                final progressImageUrl = exercise['progress_imageUrl'] ?? 'https://drive.google.com/uc?export=download&id=13ApwO6STUQtZKqC5cPD5U83QXEOMoBCc';

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: ProgressCard(
                                    title: title ?? 'Unknown',
                                    description: desc ?? 'No description',
                                    lessonCount: score is int ? score : (score as num).toInt(),
                                    backgroundColor:
                                        colors[index % colors.length],
                                    imageUrl: progressImageUrl,
                                    progressValue: accuracy / 100,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        /* ----- available exercises ----- */
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).availableExercises,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => widget.onSelectPage(1),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];

                              final title = isArabic
                                  ? exercise['arabic_name']
                                  : exercise['name'];
                              final arabicTitle =
                                  exercise['arabic_name'] ?? '';

                              /* ---------- FIX #1: use 'id' from GraphQL ---------- */
                              final exerciseId = exercise['id'] ?? '';

                              final progress = exercise['progress'];
                              final accuracy =
                                  (progress?['progressPercentage'] ?? 0.0)
                                      .toDouble();

                              // Use exercise_imageUrl from API if available
                              final exerciseImageUrl = exercise['exercise_imageUrl'] ?? 'https://drive.google.com/uc?export=view&id=1IS7-4KoNMd5WgBGHdOvyhs2XWb4VA4RC';

                              return ExerciseCard(
                                exerciseId: exerciseId,
                                imageUrl: exerciseImageUrl,
                                title: title ?? 'Unknown',
                                arabicTitle: arabicTitle,
                                lecturesCount: accuracy.toInt(),
                                learner: widget.learner!,
                                color: _primaryColor,
                                exerciseImageUrl: exerciseImageUrl,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/exercise-levels',
                                    arguments: {
                                      'exerciseId': exerciseId,
                                      'exerciseName': title ?? 'Unknown',
                                      'exerciseArabicName': arabicTitle,
                                      'exerciseImageUrl': exerciseImageUrl,
                                      'learner': widget.learner!,
                                    },
                                  );
                                },
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
    );
  }
}
