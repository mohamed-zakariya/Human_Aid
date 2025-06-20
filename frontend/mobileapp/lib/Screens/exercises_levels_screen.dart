import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/level.dart';
import '../models/learner.dart';
import '../Services/level_service.dart';
import '../graphql/graphql_client.dart';
import '../../generated/l10n.dart';
import 'level_screen.dart';
import 'widgets/level_card.dart';

class ExerciseLevelsScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String exerciseArabicName;
  final String? exerciseImageUrl; // Now optional
  final Learner learner;

  const ExerciseLevelsScreen({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseArabicName,
    this.exerciseImageUrl, // Not required
    required this.learner,
  }) : super(key: key);

  @override
  State<ExerciseLevelsScreen> createState() => _ExerciseLevelsScreenState();
}

class _ExerciseLevelsScreenState extends State<ExerciseLevelsScreen> {
  late Future<List<Level>> _levelsFuture;
  String? _exerciseImageUrl;
  bool _loadingImage = false;
  final Color _primaryColor = const Color(0xFF6C63FF);
  String? _pendingExerciseId;

  @override
  void initState() {
    super.initState();
    _exerciseImageUrl = widget.exerciseImageUrl;
    _levelsFuture = _fetchLevelsAndMaybeImage();
  }

  Future<List<Level>> _fetchLevelsAndMaybeImage() async {
    // Use the new service method to get both levels and exercise object
    final result = await LevelService.getLevelsAndExercise(widget.exerciseId);
    final exercise = result['exercise'];
    if (_exerciseImageUrl == null && exercise != null && exercise['exercise_imageUrl'] != null) {
      setState(() {
        _exerciseImageUrl = exercise['exercise_imageUrl'] as String?;
      });
    }
    return result['levels'] as List<Level>;
  }

  void _navigateToGames(Level level) {
    // Navigate to games screen for this level
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelScreen(
          level: level,
          learner: widget.learner,
          exerciseId: widget.exerciseId,
          levelObjectId: level.id,
          exerciseImageUrl: _exerciseImageUrl ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final exerciseTitle = isArabic ? widget.exerciseArabicName : widget.exerciseName;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern app bar with gradient
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exerciseTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _primaryColor,
                      _primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (_loadingImage)
                      const Center(child: CircularProgressIndicator())
                    else if (_exerciseImageUrl != null && _exerciseImageUrl!.isNotEmpty)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Image.network(
                            _exerciseImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    // Decorative shapes
                    Positioned(
                      right: -50,
                      top: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Levels content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Levels section title
                  Text(
                    S.of(context).levels,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).selectLevelToStart,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Levels list
                  FutureBuilder<List<Level>>(
                    future: _levelsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  S.of(context).errorLoadingLevels,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _levelsFuture = LevelService.getLevelsForExercise(widget.exerciseId);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(S.of(context).tryAgain),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final levels = snapshot.data ?? [];
                      
                      if (levels.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  color: Colors.grey[400],
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  S.of(context).noLevelsAvailable,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      // Sort levels by level number
                      levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          return LevelCard(
                            level: levels[index],
                            isArabic: isArabic,
                            colorIndex: index,
                            onTap: () => _navigateToGames(levels[index]),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}