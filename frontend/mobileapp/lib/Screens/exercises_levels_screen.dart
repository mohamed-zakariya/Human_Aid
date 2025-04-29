import 'package:flutter/material.dart';
import '../models/level.dart';
import '../models/learner.dart';
import '../services/level_service.dart';
import '../../generated/l10n.dart';
import 'games_screen.dart';
import 'widgets/level_card.dart';

class ExerciseLevelsScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String exerciseArabicName;
  final Learner learner;

  const ExerciseLevelsScreen({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseArabicName,
    required this.learner,
  }) : super(key: key);

  @override
  State<ExerciseLevelsScreen> createState() => _ExerciseLevelsScreenState();
}

class _ExerciseLevelsScreenState extends State<ExerciseLevelsScreen> {
  late Future<List<Level>> _levelsFuture;
  final Color _primaryColor = const Color(0xFF6C63FF);
  
  @override
  void initState() {
    super.initState();
    _levelsFuture = LevelService.getLevelsForExercise(widget.exerciseId);
  }

  void _navigateToGames(Level level) {
    // Navigate to games screen for this level
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamesScreen(
          level: level,
          learner: widget.learner,
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
                    // Background pattern (optional)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://drive.google.com/uc?export=view&id=1IS7-4KoNMd5WgBGHdOvyhs2XWb4VA4RC',
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