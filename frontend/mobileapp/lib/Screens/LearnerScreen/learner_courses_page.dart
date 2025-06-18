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
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
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
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check if the context is still mounted and widgets exist
      if (!mounted) return;

      // Verify that the target widgets exist before showing tutorial
      if (_canShowTutorial()) {
        await prefs.setBool('hasShownCoursePageTutorial', true);
        _showTutorial();
      }
    }
  }


  void _showTutorial() {
    if (!mounted) return;

    try {
      TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.black.withOpacity(0.8),
        textSkip: S.of(context).tutorialSkip,
        paddingFocus: 8,
        alignSkip: Alignment.bottomRight,
        onFinish: () {
          print("Course page tutorial finished");
        },
        onClickTarget: (target) {
          print('onClickTarget: $target');
        },
        onSkip: () {
          print("Course page tutorial skipped");
          return true;
        },
      ).show(context: context);
    } catch (e) {
      print("Error showing tutorial: $e");
    }
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "CourseCard",
        keyTarget: _firstCourseKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
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
      TargetFocus(
        identify: "PlayButton",
        keyTarget: _playButtonKey,
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
                      S.of(context).tutorialPlayButtonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).tutorialPlayButtonDescription,
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
      TargetFocus(
        identify: "ExpandButton",
        keyTarget: _expandButtonKey,
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
                      S.of(context).tutorialExpandButtonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).tutorialExpandButtonDescription,
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
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + idx * 100),
          child: _ExerciseExpansionTile(
            key: idx == 0 ? _firstCourseKey : null,
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

  @override
  State<_ExerciseExpansionTile> createState() => _ExerciseExpansionTileState();
}

class _ExerciseExpansionTileState extends State<_ExerciseExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  Future<List<Level>>? _levelsFuture;

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
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _expansionController.forward();
        _levelsFuture ??=
            LevelService.getLevelsForExercise(widget.exercise['id']);
      } else {
        _expansionController.reverse();
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Container(
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
              child: _expanded ? _buildExpandedContent() : const SizedBox
                  .shrink(),
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
    return InkWell(
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
    );
  }
}