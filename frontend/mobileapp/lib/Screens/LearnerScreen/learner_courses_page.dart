// lib/screens/learner_courses_page.dart
import 'package:flutter/material.dart';
import 'package:mobileapp/Services/learner_home_service.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/level.dart';
import 'package:mobileapp/Services/level_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../generated/l10n.dart';
import '../../models/game.dart';

class LearnerCoursesPage extends StatefulWidget {
  final Learner? learner;
  const LearnerCoursesPage({super.key, this.learner});

  @override
  State<LearnerCoursesPage> createState() => _LearnerCoursesPageState();
}

class _LearnerCoursesPageState extends State<LearnerCoursesPage>
    with TickerProviderStateMixin {
  Future<List<Map<String, dynamic>>>? _exercisesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Tutorial keys
  final GlobalKey _firstCourseKey = GlobalKey();
  final GlobalKey _expandButtonKey = GlobalKey();
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey _levelsKey = GlobalKey();
  final GlobalKey _gameChipsKey = GlobalKey();
  final GlobalKey _levelButtonKey = GlobalKey();


  bool _isTutorialActive = false;
  bool _isExpansionInProgress = false;
  int _currentTutorialStep = 0;
  GlobalKey<_ExerciseExpansionTileState>? _firstExerciseKey;
  TutorialCoachMark? _tutorialCoachMark; // Store reference to tutorial

  // vibrant colour palette
  final Color _primaryColor   = const Color(0xFF6C63FF);
  final Color _secondaryColor = const Color(0xFF8B5FBF);
  final Color _accentColor    = const Color(0xFF00BCD4);
  final Color _cardColor1     = const Color(0xFF6C63FF);
  final Color _cardColor2     = const Color(0xFF4A80F0);
  final Color _cardColor3     = const Color(0xFF3AA8A8);
  final Color _cardColor4     = const Color(0xFF96CEB4);
  final Color _cardColor5     = const Color(0xFFFECA57);




  // --------------------------------------------------------------------------
  // Helpers (guarantee *non-null* names)
  // --------------------------------------------------------------------------
  String _safeGameName(Game game, BuildContext ctx) {
    final isArabic  = Localizations.localeOf(ctx).languageCode == 'ar';
    final candidate = isArabic ? game.arabicName : game.name;
    return candidate?.trim().isNotEmpty == true
        ? candidate!
        : (isArabic ? 'لعبة' : 'Game');
  }

  String _safeExerciseName(Map<String, dynamic> ex, BuildContext ctx) {
    final isArabic  = Localizations.localeOf(ctx).languageCode == 'ar';
    final candidate =
    isArabic ? ex['arabic_name'] as String? : ex['name'] as String?;
    return candidate?.trim().isNotEmpty == true
        ? candidate!
        : (isArabic ? 'تمرين' : 'Exercise');
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    if (widget.learner?.id != null) {
      _exercisesFuture =
          LearnerHomeService.fetchLearnerHomeData(widget.learner!.id!);
      _animationController.forward();
    }

    // Check and show tutorial after the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  bool _canShowTutorial() {
    // Check if the required keys have widgets attached
    return _firstCourseKey.currentContext != null;
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownCoursePageTutorial') ?? false;

    if (!hasShown) {
      // Wait for the exercises to load completely
      await _exercisesFuture;

      // Additional delay to ensure widgets are rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if the context is still mounted and widgets exist
      if (!mounted) return;

      // Verify that the target widgets exist before showing tutorial
      if (_canShowTutorial()) {
        await prefs.setBool('hasShownCoursePageTutorial', true);
        _showTutorial();
      }
    }
  }

  void _nextTutorialStep() {
    if (!mounted || !_isTutorialActive) return;

    setState(() {
      _currentTutorialStep++;
    });

    print("Advanced to tutorial step: $_currentTutorialStep");
  }

  void _showTutorial() {
    if (!mounted) return;

    setState(() {
      _isTutorialActive = true;
      _currentTutorialStep = 0; // Start at step 0
    });

    try {
      _tutorialCoachMark = TutorialCoachMark(
        targets: _createInitialTargets(),
        colorShadow: Colors.black.withOpacity(0.8),
        textSkip: S.of(context).tutorialSkip,
        paddingFocus: 8,
        alignSkip: Alignment.bottomRight,
        onFinish: () {
          setState(() {
            _isTutorialActive = false;
            _currentTutorialStep = 0;
          });
          print("Course page tutorial finished");
        },
        onClickTarget: (target) {
          print('onClickTarget: ${target.identify}');

          // Handle mandatory clicks and progress steps
          if (target.identify == "CourseCard") {
            print("Course card clicked during tutorial");
            _nextTutorialStep();
          } else if (target.identify == "ExpandButton") {
            _nextTutorialStep();
            print("Expand button clicked during tutorial");

            // Force expand the first exercise and wait for completion
            print("1jjjjjjjjjjjjj");
            print(_currentTutorialStep);
            if (_currentTutorialStep == 2) {
              print("2jjjjjjjjjjjjj");
              _forceExpandFirstExercise();
            }
          } else if (target.identify == "PlayButton") {
            // Navigate to exercise levels
            _nextTutorialStep();
            _navigateToMainExercise();
          }
        },
        onClickTargetWithTapPosition: (target, tapDetails) {
          print('onClickTargetWithTapPosition: ${target.identify}');
          // Handle the target click and advance step
          if (target.identify == "CourseCard") {
          } else if (target.identify == "ExpandButton") {

            if (_currentTutorialStep == 2) {
              _forceExpandFirstExercise();
            }
          }
        },
        onSkip: () {
          setState(() {
            _isTutorialActive = false;
            _currentTutorialStep = 0;
          });
          print("Course page tutorial skipped");
          return true;
        },
      );

      _tutorialCoachMark!.show(context: context);
    } catch (e) {
      print("Error showing tutorial: $e");
    }
  }


  void _forceExpandFirstExercise() {
    print("Attempting to force expand first exercise at step: $_currentTutorialStep");

    // Set flag to prevent tutorial from being terminated
    _isExpansionInProgress = true;

    // Add a small delay to ensure the widget is fully built
    Future.delayed(Duration(milliseconds: 200), () {
      print("After 200ms delay - mounted: $mounted, tutorialActive: $_isTutorialActive");

      if (!mounted) {
        _isExpansionInProgress = false;
        return;
      }

      // Check if the key and state are available
      if (_firstExerciseKey?.currentState != null) {
        print("Found first exercise state, forcing expand");
        _firstExerciseKey!.currentState!.forceExpand();

        print("Before 1200ms delay - mounted: $mounted, tutorialActive: $_isTutorialActive");

        // Use a more reliable approach with multiple checks
        _waitForExpansionComplete();
      } else {
        print("First exercise state not available, retrying...");
        _isExpansionInProgress = false;

        // Retry after a longer delay if the state isn't ready
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted && _isTutorialActive) {
            print("Retrying force expand...");
            _forceExpandFirstExercise();
          } else {
            print("Cannot retry - mounted: $mounted, tutorialActive: $_isTutorialActive");
          }
        });
      }
    });
  }

  void _waitForExpansionComplete() {
    int attempts = 0;
    const maxAttempts = 10;
    const checkInterval = 200; // Check every 200ms

    void checkExpansion() {
      attempts++;
      print("Expansion check attempt $attempts/$maxAttempts");

      if (!mounted) {
        print("Widget not mounted, stopping expansion check");
        _isExpansionInProgress = false;
        return;
      }

      // Check if expansion is visually complete (you might need to adjust this logic)
      bool isExpanded = _firstExerciseKey?.currentState?._expanded == true;

      if (isExpanded || attempts >= maxAttempts) {
        print("Expansion detected or max attempts reached");
        _isExpansionInProgress = false;

        if (mounted && _isTutorialActive) {
          print("Proceeding with expanded tutorial");

          print("4jjjjjjjjjjjjjjjjj");
          // Add a small delay before showing expanded tutorial
          Future.delayed(Duration(milliseconds: 1000), () {
            print("5jjjjjjjjjjjjjjjjj");
            _showExpandedTutorial();
          });
        }
      } else {
        // Continue checking
        Future.delayed(Duration(milliseconds: checkInterval), checkExpansion);
      }
    }

    // Start the expansion check
    checkExpansion();
  }

  void _showExpandedTutorial() {
    if (!mounted) return;

    print("6jjjjjjjjjjjjjjj");
    print(mounted);
    print(_isTutorialActive);
    setState(() {
      _isTutorialActive = true;
    });
    // Wait a bit more to ensure the expanded content is fully rendered
    Future.delayed(Duration(milliseconds: 500), () {
      
      if (!mounted || !_isTutorialActive) return;

      try {
        _tutorialCoachMark = TutorialCoachMark(
          targets: _createExpandedTargets(),
          colorShadow: Colors.black.withOpacity(0.8),
          textSkip: S.of(context).tutorialSkip,
          paddingFocus: 8,
          alignSkip: Alignment.bottomRight,
          onFinish: () {
            setState(() {
              _isTutorialActive = false;
              _currentTutorialStep = 0;
            });
            print("Course page tutorial finished at step: $_currentTutorialStep");
          },
          onClickTarget: (target) {
            print('onClickTarget: ${target.identify} at step: $_currentTutorialStep');

            if (target.identify == "LevelsSection") {
            } else if (target.identify == "LevelButton") {
            } else if (target.identify == "GameChips") {
            } else if (target.identify == "PlayButton") {
              // _nextTutorialStep();
              _navigateToMainExercise();
            }
          },
          onSkip: () {
            setState(() {
              _isTutorialActive = false;
              _currentTutorialStep = 0;
            });
            print("Course page tutorial skipped at step: $_currentTutorialStep");
            return true;
          },
        );

        _tutorialCoachMark!.show(context: context);
      } catch (e) {
        print("Error showing expanded tutorial: $e");
        // Fallback - end tutorial
        setState(() {
          _isTutorialActive = false;
          _currentTutorialStep = 0;
        });
      }
    });
  }


  void _navigateToMainExercise() {
    // Navigate to the first exercise
    final exercises = (_exercisesFuture as Future<List<Map<String, dynamic>>>);
    exercises.then((exerciseList) {
      if (exerciseList.isNotEmpty) {
        final firstExercise = exerciseList.first;
        Navigator.pushNamed(context, '/exercise-levels', arguments: {
          'exerciseId': firstExercise['id'],
          'exerciseName': _safeExerciseName(firstExercise, context),
          'exerciseArabicName': firstExercise['arabic_name'],
          'learner': widget.learner,
        });
      }
    });
  }

  List<TargetFocus> _createExpandedTargets() {
    List<TargetFocus> targets = [];

    // Only add targets if the keys exist and have contexts
    if (_levelsKey.currentContext != null || true) {

      print("Expanded targets not ready, retrying in 300ms...");

      targets.add(
        TargetFocus(
          identify: "LevelsSection",
          keyTarget: _levelsKey,
          alignSkip: Alignment.topLeft,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 45),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).levelsSectionTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        S.of(context).levelsSectionDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // Add the new level button target
    if (_levelButtonKey.currentContext != null || true) {
      targets.add(
        TargetFocus(
          identify: "LevelButton",
          keyTarget: _levelButtonKey,
          alignSkip: Alignment.topLeft,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).levelsSectionTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        S.of(context).levelsSectionDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (_gameChipsKey.currentContext != null || true) {
      targets.add(
        TargetFocus(
          identify: "GameChips",
          keyTarget: _gameChipsKey,
          alignSkip: Alignment.topLeft,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).gamesNavigationTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        S.of(context).gamesNavigationDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    // Always add the play button target
    targets.add(
      TargetFocus(
        identify: "PlayButton",
        keyTarget: _playButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).mainCourseNavigationTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).mainCourseNavigationDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  List<TargetFocus> _createInitialTargets() {
    return [
      // Step 1: Show the course card (Word Stage)
      TargetFocus(
        identify: "CourseCard",
        keyTarget: _firstCourseKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20,100, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).tutorialCourseCardTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).tutorialCourseCardDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // Step 2: Show expand button (mandatory click)
      TargetFocus(
        identify: "ExpandButton",
        keyTarget: _expandButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).expandLevelsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).expandLevelsDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tutorialCoachMark?.finish();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (widget.learner?.id == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(isArabic ? 'لا يوجد متعلم' : 'No learner found',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: _primaryColor.withOpacity(.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child:
                      const Icon(Icons.school, color: Colors.white, size: 38),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(isArabic ? 'اختر تمرين' : 'Choose Exercise',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor)),
                    ),
                  ],
                ),
              ),
            ),
            // body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverToBoxAdapter(
                child: _buildContent(isArabic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // FutureBuilder wrapper
  // --------------------------------------------------------------------------
  Widget _buildContent(bool isArabic) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _exercisesFuture,
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return _buildLoadingState();
      }
      if (snap.hasError) {
        return _buildErrorState(snap.error.toString(), isArabic);
      }
      final exercises = snap.data ?? [];
      if (exercises.isEmpty) {
        return _buildEmptyState(isArabic);
      }
      return _buildExercisesList(exercises, isArabic);
    },
  );

  // --------------------------------------------------------------------------
  // Loading / error / empty
  // --------------------------------------------------------------------------
  Widget _buildLoadingState() => Column(
    children: List.generate(
        3,
            (_) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(.15),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 3)),
        )),
  );

  Widget _buildErrorState(String error, bool isArabic) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.red.withOpacity(.1), Colors.red.withOpacity(.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(.2), width: 2)),
    child: Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red[400], size: 60),
        const SizedBox(height: 20),
        Text(isArabic ? 'حدث خطأ' : 'Something went wrong',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red[700])),
        const SizedBox(height: 12),
        Text(error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red[600])),
      ],
    ),
  );

  Widget _buildEmptyState(bool isArabic) => Container(
    padding: const EdgeInsets.all(50),
    child: Column(
      children: [
        Icon(Icons.quiz_outlined, size: 100, color: Colors.grey[400]),
        const SizedBox(height: 24),
        Text(S.of(context).noExercisesAvailable,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );

  // --------------------------------------------------------------------------
  // Exercise list
  // --------------------------------------------------------------------------
  Widget _buildExercisesList(List<Map<String, dynamic>> exercises, bool isArabic) {
    return Column(
      children: exercises.asMap().entries.map((e) {
        final idx = e.key;
        final ex = e.value;

        // Create a GlobalKey for the first exercise to control it
        if (idx == 0 && _firstExerciseKey == null) {
          _firstExerciseKey = GlobalKey<_ExerciseExpansionTileState>();
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + idx * 100),
          child: _ExerciseExpansionTile(
            key: idx == 0 ? _firstExerciseKey : null,
            containerKey: idx == 0 ? _firstCourseKey : null,
            exercise: ex,
            learner: widget.learner!,
            isArabic: isArabic,
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
            accentColor: _accentColor,
            cardColor: _getCardColor(idx),
            safeGameName: _safeGameName,
            safeExerciseName: _safeExerciseName,
            playButtonKey: idx == 0 ? _playButtonKey : null,
            expandButtonKey: idx == 0 ? _expandButtonKey : null,
            levelsKey: idx == 0 ? _levelsKey : null,
            gameChipsKey: idx == 0 ? _gameChipsKey : null,
            levelButtonKey: idx == 0 ? _levelButtonKey : null, // Add this line
            isTutorialActive: _isTutorialActive,
          ),
        );
      }).toList(),
    );
  }

  Color _getCardColor(int i) =>
      [_cardColor1, _cardColor2, _cardColor3, _cardColor4, _cardColor5][i % 5];
}

// ═════════════════════════════════════════════════════════════════════════════
// Expansion-tile widget (updated with tutorial keys and level logo navigation)
// ═════════════════════════════════════════════════════════════════════════════
class _ExerciseExpansionTile extends StatefulWidget {
  const _ExerciseExpansionTile({
    Key? key,
    required this.exercise,
    required this.learner,
    required this.isArabic,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.cardColor,
    required this.safeGameName,
    required this.safeExerciseName,
    this.playButtonKey,
    this.expandButtonKey,
    this.levelsKey,
    this.gameChipsKey,
    this.levelButtonKey, // Add this line
    this.containerKey,
    this.isTutorialActive = false,
  }) : super(key: key);

  final Map<String, dynamic>                   exercise;
  final Learner                                learner;
  final bool                                   isArabic;
  final Color                                  primaryColor;
  final Color                                  secondaryColor;
  final Color                                  accentColor;
  final Color                                  cardColor;
  final String Function(Game, BuildContext)    safeGameName;
  final String Function(Map<String, dynamic>, BuildContext) safeExerciseName;
  final GlobalKey?                             playButtonKey;
  final GlobalKey?                             expandButtonKey;
  final GlobalKey?                             levelsKey;
  final GlobalKey?                             gameChipsKey;
  final GlobalKey?                             levelButtonKey; // Add this line
  final GlobalKey?                             containerKey;
  final bool                                   isTutorialActive;

  @override
  State<_ExerciseExpansionTile> createState() => _ExerciseExpansionTileState();
}

class _ExerciseExpansionTileState extends State<_ExerciseExpansionTile>
    with SingleTickerProviderStateMixin {

  bool _expanded = false;
  Future<List<Level>>? _levelsFuture;
  bool _gameChipKeyAssigned = false;
  bool _levelButtonKeyAssigned = false; // Add this line

  late AnimationController _expansionController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _expansionController =
        AnimationController(
            vsync: this, duration: const Duration(milliseconds: 300));
    _rotationAnimation =
        Tween<double>(begin: 0, end: .5).animate(CurvedAnimation(
          parent: _expansionController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  // Navigation helpers  ––––––––––––––––––––––––––––––––––––––––––––––––––––

  void _goToMainExercise() {
    Navigator.pushNamed(context, '/exercise-levels', arguments: {
      'exerciseId': widget.exercise['id'],
      'exerciseName': widget.safeExerciseName(widget.exercise, context),
      'exerciseArabicName': widget.exercise['arabic_name'],
      'learner': widget.learner,
    });
  }

  void _goToLevel(Level level) {
    Navigator.pushNamed(context, '/games', arguments: {
      'level': level,
      'learner': widget.learner,
      'exerciseId': widget.exercise['id'],
    });
  }

  void _goToLevelInfo(Level level) {
    Navigator.pushNamed(context, '/level-info', arguments: {
      'level': level,
      'learner': widget.learner,
      'exerciseId': widget.exercise['id'],
    });
  }

  void _goToGame(Game game) {
    Navigator.pushNamed(context, '/${game.gameId}', arguments: {
      'gameId': game.gameId,
      'gameName': widget.safeGameName(game, context),
      'learner': widget.learner,
    });
  }

  // UI –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

  void _toggleExpanded() {
    print("Toggle expanded called, tutorial active: ${widget.isTutorialActive}");

    // Don't allow manual expansion during tutorial
    if (widget.isTutorialActive) {
      print("Blocking manual expansion during tutorial");
      return;
    }

    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _expansionController.forward();
        _levelsFuture ??= LevelService.getLevelsForExercise(widget.exercise['id']);
        print("Exercise expanded manually");
      } else {
        _expansionController.reverse();
        print("Exercise collapsed");
      }
    });
  }

  void forceExpand() {
    print("forceExpand called on exercise tile");
    if (!_expanded) {
      setState(() {
        _expanded = true;
        _levelsFuture ??= LevelService.getLevelsForExercise(widget.exercise['id']);
      });

      // Animate the expansion
      _expansionController.forward();
      print("Exercise expanded successfully");
    } else {
      print("Exercise already expanded");
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Container(
      key: widget.containerKey,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.cardColor,
            widget.cardColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.cardColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildHeader(exercise),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _expanded ? null : 0,
              child: _expanded ? _buildExpandedContent() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isArabic
                      ? (exercise['arabic_name'] ?? 'Unknown')
                      : (exercise['name'] ?? 'Unknown'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isArabic
                      ? (exercise['arabic_description'] ?? '')
                      : (exercise['english_description'] ?? ''),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              _buildActionButton(
                key: widget.playButtonKey,
                icon: Icons.play_circle_fill,
                color: Colors.white,
                onPressed: _goToMainExercise,
                tooltip: widget.isArabic ? 'التمرين الرئيسي' : 'Main Exercise',
              ),
              const SizedBox(height: 12),
              _buildExpandButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    Key? key,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 26),
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildExpandButton() {
    return Container(
      key: widget.expandButtonKey,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 3.14159,
            child: IconButton(
              icon: const Icon(
                Icons.expand_more,
                color: Colors.white,
                size: 26,
              ),
              onPressed: _toggleExpanded,
              splashRadius: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      key: widget.levelsKey, // Add this key
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: FutureBuilder<List<Level>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final levels = snapshot.data ?? [];
          if (levels.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.layers_clear, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 12),
                  Text(
                    widget.isArabic ? 'لا توجد مستويات' : 'No levels available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                widget.isArabic ? 'المستويات المتاحة:' : 'Available Levels:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: widget.cardColor,
                ),
              ),
              const SizedBox(height: 16),
              ...levels.map((level) => _buildLevelCard(level)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(Level level) {

    final shouldAssignKey = widget.levelButtonKey != null && !_levelButtonKeyAssigned;
    if (shouldAssignKey) {
      _levelButtonKeyAssigned = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.cardColor.withOpacity(0.1),
            widget.cardColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.cardColor.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _goToLevelInfo(level),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.cardColor,
                        widget.cardColor.withOpacity(0.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: widget.cardColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.isArabic ? level.arabicName : level.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              _buildActionButton(
                key: shouldAssignKey ? widget.levelButtonKey : null, // Add this line
                icon: Icons.school,
                color: widget.cardColor,
                onPressed: () => _goToLevel(level),
                tooltip: widget.isArabic ? 'مستوى التمرين' : 'Level Main',
              ),
            ],
          ),
          if (level.games.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.isArabic ? 'الألعاب:' : 'Games:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.cardColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: level.games.map((game) => _buildGameChip(game))
                  .toList(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget.isArabic ? 'لا توجد ألعاب' : 'No games for this level',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameChip(Game game) {
    // Only assign the key to the very first game chip and only once
    final shouldAssignKey = widget.gameChipsKey != null && !_gameChipKeyAssigned;
    if (shouldAssignKey) {
      _gameChipKeyAssigned = true;
    }

    return Container(
      key: shouldAssignKey ? widget.gameChipsKey : null,
      child: InkWell(
        onTap: () => _goToGame(game),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.cardColor, widget.cardColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: widget.cardColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videogame_asset,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isArabic ? game.arabicName : game.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}