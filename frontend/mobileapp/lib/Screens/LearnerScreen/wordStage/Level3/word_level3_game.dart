import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:mobileapp/Services/tts_service.dart';
import 'package:mobileapp/Services/add_score_service.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthsOrderGameScreen extends StatefulWidget {
  const MonthsOrderGameScreen({super.key});

  @override
  State<MonthsOrderGameScreen> createState() => _MonthsOrderGameScreenState();
}

class _MonthsOrderGameScreenState extends State<MonthsOrderGameScreen> with TickerProviderStateMixin {
  // Audio players for different sound effects
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _dropPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final TTSService ttsService = TTSService();

  // Month data
  final List<MonthData> arabicMonths = [
    MonthData('يناير', 'كانون الثاني', 'شهر البداية'),
    MonthData('فبراير', 'شباط', 'شهر قصير'),
    MonthData('مارس', 'آذار', 'بداية الربيع'),
    MonthData('أبريل', 'نيسان', 'شهر الزهور'),
    MonthData('مايو', 'أيار', 'شهر الخضرة'),
    MonthData('يونيو', 'حزيران', 'بداية الصيف'),
    MonthData('يوليو', 'تموز', 'شهر الحرارة'),
    MonthData('أغسطس', 'آب', 'شهر السفر'),
    MonthData('سبتمبر', 'أيلول', 'شهر العودة للمدرسة'),
    MonthData('أكتوبر', 'تشرين الأول', 'بداية الخريف'),
    MonthData('نوفمبر', 'تشرين الثاني', 'شهر تساقط الأوراق'),
    MonthData('ديسمبر', 'كانون الأول', 'شهر نهاية العام'),
  ];

  bool showingLevadant = false;
  late List<MonthData> shuffledMonths;
  late List<MonthData?> orderedMonths;
  int _score = 0; // Changed to private to match service parameter
  int currentLevel = 1;
  int totalLevels = 10;
  bool isLevelComplete = false;
  bool isDescendingOrder = false;
  bool isLoading = true;

  // Animation controllers
  late AnimationController _successAnimationController;
  late AnimationController _levelCompleteController;
  late Animation<double> _scaleAnimation;

  // Game variables
  late int monthsToOrder;
  late List<MonthData> currentLevelMonths;

  // Widget configuration for score service
  late Map<String, dynamic> gameData; // ✅ Renamed from 'widget'

  // SharedPreferences keys and values
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? roundKey;
  String? scoreKey;
  String? levelGameId;

  @override
  void initState() {
    super.initState();

    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _levelCompleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _levelCompleteController,
        curve: Curves.elasticOut,
      ),
    );

    _initSoundEffects();
    _initializeFromSharedPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize widget configuration from route arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    gameData = {
      'totalQuestions': totalLevels,
      ...args,
    };
  }

  Future<void> _initializeFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the stored IDs from SharedPreferences
    exerciseId = prefs.getString('exerciseId');
    levelId = prefs.getString('levelId');
    learnerId = prefs.getString('learnerId');
    gameId = prefs.getString('gameId');
    levelGameId = prefs.getString('levelGameId');



    if (levelId != null && gameId != null) {
      // Create keys for this specific level and game
      roundKey = '${levelId}_${gameId}_${levelGameId}_round';
      scoreKey = '${levelId}_${gameId}_${levelGameId}_score';

      // Initialize round and score from SharedPreferences
      currentLevel = prefs.getInt(roundKey!) ?? 1; // Start from 1
      _score = prefs.getInt(scoreKey!) ?? 0;

      // Ensure currentLevel is within bounds (1 to totalLevels)
      if (currentLevel < 1) currentLevel = 1;
      if (currentLevel > totalLevels) currentLevel = totalLevels;

      // Ensure score is within bounds (0 to totalLevels)
      if (_score < 0) _score = 0;
      if (_score > totalLevels) _score = totalLevels;
    }

    setState(() {
      isLoading = false;
    });

    // Load the current level
    _loadLevel();
  }

  Future<void> _saveProgressToSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, currentLevel);
      await prefs.setInt(scoreKey!, _score);
    }
  }

  Future<void> _initSoundEffects() async {
    try {
      await _correctPlayer.setSource(AssetSource('sounds/correct.wav'));
      await _incorrectPlayer.setSource(AssetSource('sounds/incorrect.wav'));
      await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
      await _successPlayer.setSource(AssetSource('sounds/success.wav'));
    } catch (e) {
      debugPrint('Failed to load sound assets: $e');
    }

    try {
      await ttsService.initialize(language: "ar");
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
    }
  }

  @override
  void dispose() {
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _clickPlayer.dispose();
    _dropPlayer.dispose();
    _successPlayer.dispose();
    ttsService.stop();
    _successAnimationController.dispose();
    _levelCompleteController.dispose();
    super.dispose();
  }

  void _loadLevel() {
    setState(() {
      isDescendingOrder = currentLevel > 5;

      if (currentLevel == 5 || currentLevel == 10) {
        monthsToOrder = 12;
      } else {
        monthsToOrder = 4;
      }

      List<MonthData> baseMonths = List.from(arabicMonths);

      if (monthsToOrder < 12) {
        List<int> indices = List.generate(12, (i) => i);
        indices.shuffle(Random());
        indices = indices.take(4).toList();
        indices.sort();

        baseMonths = indices.map((i) => baseMonths[i]).toList();
      }

      if (isDescendingOrder) {
        baseMonths = baseMonths.reversed.toList();
      }

      currentLevelMonths = List.from(baseMonths);
      shuffledMonths = List.from(baseMonths)..shuffle(Random());
      orderedMonths = List.filled(monthsToOrder, null);

      isLevelComplete = false;
      _successAnimationController.reset();
      _levelCompleteController.reset();
    });
  }

  void _checkOrderCorrectness() {
    if (!orderedMonths.contains(null)) {
      bool isCorrect = true;

      for (int i = 0; i < orderedMonths.length; i++) {
        if (orderedMonths[i] != currentLevelMonths[i]) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        _handleCorrectOrder();
      } else {
        _handleIncorrectOrder();
      }
    }
  }

  void _handleCorrectOrder() {
    try {
      _successPlayer.resume();
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }

    setState(() {
      isLevelComplete = true;
      _score++; // Increment score for correct answer
    });

    // Save progress after scoring
    _saveProgressToSharedPreferences();

    _levelCompleteController.forward();
    _showLevelCompletionMessage(true);
  }

  void _handleIncorrectOrder() {
    try {
      _incorrectPlayer.resume();
    } catch (e) {
      debugPrint('Error playing incorrect sound: $e');
    }

    setState(() {
      isLevelComplete = true; // Complete level even on incorrect answer
    });

    // Save progress even on incorrect answer
    _saveProgressToSharedPreferences();

    _showLevelCompletionMessage(false);
  }

  void _showLevelCompletionMessage(bool isSuccess) {
    final l10n = S.of(context);
    String message;

    if (isSuccess) {
      if (currentLevel == totalLevels) {
        message = l10n.finalLevelSuccess;
      } else {
        message = l10n.levelSuccess(currentLevel);
      }
    } else {
      // Show encouraging message for incorrect answers
      message = "استمر في المحاولة! كل تجربة تجعلك أقوى."; // "Keep trying! Every attempt makes you stronger."
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _moveToNextLevel() {
    try {
      _clickPlayer.resume();
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }

    if (currentLevel < totalLevels) {
      setState(() {
        currentLevel++;
      });

      // Save progress after moving to next level
      _saveProgressToSharedPreferences();

      _loadLevel();
    } else {
      _showGameCompletionDialog();
    }
  }

  void _showGameCompletionDialog() {
    final l10n = S.of(context);
    try {
      _successPlayer.resume();
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }

    // Send score to service
    try {
      AddScoreService.updateScore(
        score: _score,
        outOf: gameData['totalQuestions'] as int,
      );
    } catch (e) {
      debugPrint('Error updating score: $e');
    }

    // Clear the saved progress since game is completed
    _clearProgressFromSharedPreferences();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.monthsOrderTitle, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(height: 20),
            // Show encouraging message regardless of score
            Text(
              _getEncouragingMessage(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    try {
                      _clickPlayer.resume();
                    } catch (e) {
                      debugPrint('Error playing click sound: $e');
                    }
                    Navigator.pop(context);
                    _restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F73FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(l10n.playAgain, style: const TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      _clickPlayer.resume();
                    } catch (e) {
                      debugPrint('Error playing click sound: $e');
                    }
                    Navigator.pop(context);
                    Navigator.pop(context); // exit the game screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('خروج', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> _clearProgressFromSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(roundKey!);
      await prefs.remove(scoreKey!);
    }
  }

  void _restartGame() async {
    setState(() {
      currentLevel = 1;
      _score = 0;
      isLoading = false;
    });

    // Reset SharedPreferences for this game
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, 1);
      await prefs.setInt(scoreKey!, 0);
    }

    _loadLevel();
  }

  String _getEncouragingMessage() {
    // Return encouraging messages based on score ranges, but always positive
    if (_score >= 8) {
      return "رائع جداً! أداء ممتاز في تعلم الأشهر!";
    } else if (_score >= 6) {
      return "أحسنت! تطور ملحوظ في معرفة الأشهر!";
    } else if (_score >= 4) {
      return "جيد جداً! استمر في التعلم والتطور!";
    } else if (_score >= 2) {
      return "تقدم جميل! كل خطوة تقودك للنجاح!";
    } else {
      return "بداية رائعة! التعلم رحلة جميلة استمر فيها!";
    }
  }

  void _toggleMonthNames() {
    setState(() {
      showingLevadant = !showingLevadant;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF7F73FF),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final l10n = S.of(context);

    final size = MediaQuery.of(context).size;
    int crossAxisCount;
    double childAspectRatio;

    if (monthsToOrder > 8) {
      crossAxisCount = size.width > 600 ? 4 : 2;
      childAspectRatio = size.width > 600 ? 3.0 : 2.2;
    } else if (monthsToOrder > 4) {
      crossAxisCount = size.width > 600 ? 4 : 2;
      childAspectRatio = size.width > 600 ? 3.0 : 2.5;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 2.5;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(args['gameName']),
        centerTitle: true,
        backgroundColor: const Color(0xFF7F73FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: _toggleMonthNames,
            tooltip: l10n.translateMonthsTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              try {
                _clickPlayer.resume();
              } catch (e) {
                debugPrint('Error playing click sound: $e');
              }
              _showHelpDialog(context, l10n);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF7F73FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.monthsOrderLevelInstruction(
                      currentLevel.toString(),
                      monthsToOrder.toString(),
                      isDescendingOrder ? l10n.orderDescending : l10n.orderAscending
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDescendingOrder
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDescendingOrder
                          ? 'ديسمبر ← يناير'
                          : 'يناير ← ديسمبر',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalLevels,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index < currentLevel ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFF0F0FF)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7F73FF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              l10n.orderMonthsCorrectly,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: monthsToOrder,
                              itemBuilder: (context, index) {
                                return DragTarget<MonthData>(
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: orderedMonths[index] != null
                                            ? const Color(0xFFE6F0FF)
                                            : Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: orderedMonths[index] != null
                                              ? const Color(0xFF7F73FF)
                                              : Colors.grey.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: orderedMonths[index] != null
                                          ? MonthCard(
                                        month: orderedMonths[index]!,
                                        showingLevadant: showingLevadant,
                                        isDraggable: true,
                                        index: index + 1,
                                        onTap: () {
                                          try {
                                            ttsService.speak(orderedMonths[index]!.name);
                                          } catch (e) {
                                            debugPrint('TTS error: $e');
                                          }
                                        },
                                      )
                                          : Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onAccept: (MonthData month) {
                                    setState(() {
                                      shuffledMonths.remove(month);

                                      if (orderedMonths[index] != null) {
                                        shuffledMonths.add(orderedMonths[index]!);
                                      }

                                      orderedMonths[index] = month;
                                      _checkOrderCorrectness();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: isLevelComplete
                        ? Center(
                      child: ElevatedButton(
                        onPressed: _moveToNextLevel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7F73FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          currentLevel < totalLevels
                              ? l10n.next
                              : l10n.done,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: shuffledMonths.length,
                      itemBuilder: (context, index) {
                        return Draggable<MonthData>(
                          data: shuffledMonths[index],
                          feedback: Material(
                            color: Colors.transparent,
                            child: MonthCard(
                              month: shuffledMonths[index],
                              showingLevadant: showingLevadant,
                              isDraggable: true,
                              index: null,
                              onTap: () {},
                            ),
                          ),
                          childWhenDragging: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: MonthCard(
                              month: shuffledMonths[index],
                              showingLevadant: showingLevadant,
                              isDraggable: true,
                              index: null,
                              onTap: () {
                                try {
                                  ttsService.speak(shuffledMonths[index].name);
                                } catch (e) {
                                  debugPrint('TTS error: $e');
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, S l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Color(0xFF7F73FF)),
            const SizedBox(width: 10),
            Text(l10n.howToPlayTitle, style: const TextStyle(color: Color(0xFF7F73FF))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.drag_indicator, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpDrag),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpOrder),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpListen),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpTranslate),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  try {
                    _clickPlayer.resume();
                  } catch (e) {
                    debugPrint('Error playing click sound: $e');
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F73FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(l10n.gotIt, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

// Month data model
class MonthData {
  final String name;
  final String levantName;
  final String description;

  MonthData(this.name, this.levantName, this.description);
}

// Month card widget
class MonthCard extends StatelessWidget {
  final MonthData month;
  final bool showingLevadant;
  final bool isDraggable;
  final int? index;
  final VoidCallback onTap;

  const MonthCard({
    super.key,
    required this.month,
    required this.showingLevadant,
    required this.isDraggable,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0FF),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F73FF).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index != null)
              Text(
                "$index",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7F73FF),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    showingLevadant ? month.levantName : month.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.volume_up,
                  size: 14,
                  color: Color(0xFF7F73FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}