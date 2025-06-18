import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../../../../Services/add_score_service.dart';
import '../../../../../generated/l10n.dart';

class DirectionGameSecondPage extends StatefulWidget {
  final int totalQuestions;

  const DirectionGameSecondPage({super.key, required this.totalQuestions});

  @override
  _DirectionGameSecondPageState createState() => _DirectionGameSecondPageState();
}

class _DirectionGameSecondPageState extends State<DirectionGameSecondPage> with SingleTickerProviderStateMixin {

  final FlutterTts flutterTts = FlutterTts();
  late Timer _timer;
  int _currentQuestionIndex = 0;
  int _timeLeft = 5;
  int _score = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isDropped = false;
  String _selectedDirection = '';
  int _remainingAttempts = 2;
  bool isLoading = true;

  // SharedPreferences keys and values
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? roundKey;
  String? scoreKey;
  String? levelGameId;

  // List of motivational messages for incorrect answers
  final List<Map<String, dynamic>> _motivationalMessages = [
    {
      'message': 'لا بأس! حاول مرة أخرى!',
      'emoji': '😊',
    },
    {
      'message': 'أنت تحاول بجهد! هذا رائع!',
      'emoji': '🌟',
    },
    {
      'message': 'المحاولة هي الخطوة الأولى للنجاح!',
      'emoji': '🚀',
    },
    {
      'message': 'كل محاولة تجعلك أقوى!',
      'emoji': '💪',
    },
    {
      'message': 'لا تستسلم! أنت تتعلم!',
      'emoji': '📚',
    },
    {
      'message': 'التعلم يحتاج للصبر! أنت تقوم بعمل رائع!',
      'emoji': '💡',
    },
    {
      'message': 'استمر في المحاولة! أنت تتقدم!',
      'emoji': '🏆',
    },
  ];

  // List of celebratory messages for correct answers
  final List<Map<String, dynamic>> _celebrationMessages = [
    {
      'message': 'رائع جداً!',
      'emoji': '🎉',
    },
    {
      'message': 'أحسنت!',
      'emoji': '👏',
    },
    {
      'message': 'عمل ممتاز!',
      'emoji': '🌟',
    },
    {
      'message': 'ذكي جداً!',
      'emoji': '🧠',
    },
    {
      'message': 'واصل التقدم!',
      'emoji': '🚀',
    },
  ];

  // Animation for the draggable element
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define fixed positions for each direction (not random)
  final Map<String, Map<String, dynamic>> directionData = {
    '⬆': {
      'meaning': 'أعلى',
      'position': 'top', // Position at the top of the circle
      'angle': 270.0 * (math.pi / 180.0), // Make sure we're using doubles
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '⬇': {
      'meaning': 'أسفل',
      'position': 'bottom',
      'angle': 90.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '➡': {
      'meaning': 'يمين',
      'position': 'right',
      'angle': 0.0, // Explicitly make it a double
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '⬅': {
      'meaning': 'يسار',
      'position': 'left',
      'angle': 180.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '↗': {
      'meaning': 'أعلى اليمين',
      'position': 'topRight',
      'angle': 315.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '↘': {
      'meaning': 'أسفل اليمين',
      'position': 'bottomRight',
      'angle': 45.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '↖': {
      'meaning': 'أعلى اليسار',
      'position': 'topLeft',
      'angle': 225.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
    '↙': {
      'meaning': 'أسفل اليسار',
      'position': 'bottomLeft',
      'angle': 135.0 * (math.pi / 180.0),
      'color': const Color(0xFFE0E7FF),
      'borderColor': const Color(0xFF6366F1),
    },
  };

  // Define images for different categories that can be used in the center
  final List<Map<String, dynamic>> centerImages = [
    {
      'type': 'animal',
      'icon': Icons.pets,
      'name': 'قطة',
    },
    {
      'type': 'fruit',
      'icon': Icons.apple,
      'name': 'تفاحة',
    },
    {
      'type': 'vehicle',
      'icon': Icons.directions_car,
      'name': 'سيارة',
    },
    {
      'type': 'school',
      'icon': Icons.school,
      'name': 'كتاب',
    },
    {
      'type': 'toy',
      'icon': Icons.sports_soccer,
      'name': 'كرة',
    },
  ];

  // List for shuffling questions
  late List<String> questionDirections;
  late List<Map<String, dynamic>> questionImages;

  // Store calculated positions
  final Map<String, Offset> directionPositions = {};

  // Map to track dropTargetKeys
  final Map<String, GlobalKey> dropTargetKeys = {};

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);

    // Initialize drop target keys
    directionData.keys.forEach((direction) {
      dropTargetKeys[direction] = GlobalKey();
    });

    _initializeFromSharedPreferences();
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
      _currentQuestionIndex = prefs.getInt(roundKey!) ?? 0;
      _score = prefs.getInt(scoreKey!) ?? 0;

      // Ensure currentQuestionIndex is within bounds (0 to totalQuestions-1)
      if (_currentQuestionIndex < 0) _currentQuestionIndex = 0;
      if (_currentQuestionIndex >= widget.totalQuestions) _currentQuestionIndex = widget.totalQuestions - 1;

      // Ensure score is within bounds (0 to totalQuestions)
      if (_score < 0) _score = 0;
      if (_score > widget.totalQuestions) _score = widget.totalQuestions;
    }

    _initializeGame();
  }

  Future<void> _saveProgressToSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, _currentQuestionIndex);
      await prefs.setInt(scoreKey!, _score);
    }
  }

  void _initializeGame() {
    // Create shuffled list of directions for questions
    questionDirections = directionData.keys.toList()..shuffle();

    // Create shuffled list of center images
    questionImages = List.from(centerImages)..shuffle();

    setState(() => isLoading = false);

    initTts();
    _startTimer();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak("اسحب الصورة إلى الاتجاه الصحيح");
  }

  void _startTimer() {
    _timeLeft = 8;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {  // Check if the widget is still mounted
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _showAnswer(false);
          }
        });
      }
    });
  }

  // Get a random motivational message
  Map<String, dynamic> _getRandomMotivationalMessage() {
    final random = math.Random();
    return _motivationalMessages[random.nextInt(_motivationalMessages.length)];
  }

  // Get a random celebration message
  Map<String, dynamic> _getRandomCelebrationMessage() {
    final random = math.Random();
    return _celebrationMessages[random.nextInt(_celebrationMessages.length)];
  }

  void _showAnswer(bool isCorrect) {
    _timer.cancel();
    if (mounted) {  // Check if the widget is still mounted
      setState(() {
        _showFeedback = true;
        _isCorrect = isCorrect;
        if (isCorrect) {
          _score++;
        }
      });
    }

    // Save progress after each answer
    _saveProgressToSharedPreferences();

    // Speak feedback
    if (isCorrect) {
      final celebration = _getRandomCelebrationMessage();
      flutterTts.speak("${celebration['message']}");
    } else {
      final motivation = _getRandomMotivationalMessage();
      String correctDirection = questionDirections[_currentQuestionIndex % questionDirections.length];
      String correctAnswer = directionData[correctDirection]?['meaning'] ?? '';
      flutterTts.speak(S.of(context).correctAnswerIs(correctAnswer));
    }

    // Move to next question after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;  // Check if widget is still mounted

      if (_currentQuestionIndex < widget.totalQuestions - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showFeedback = false;
          _isDropped = false;
          _selectedDirection = '';
          _remainingAttempts = 2; // Reset attempts for next question
        });
        _saveProgressToSharedPreferences();
        _startTimer();
      } else {
        // Game over - show final score
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() async {
    // Send the final score
    await AddScoreService.updateScore(
      score: _score,
      outOf: widget.totalQuestions,
    );

    // Clear the saved progress since game is completed
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(roundKey!);
      await prefs.remove(scoreKey!);
    }

    if (!mounted) return;  // Check if widget is still mounted

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              S.of(context).exerciseFinished,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _score >= widget.totalQuestions / 2 ? Icons.emoji_events : Icons.sentiment_satisfied,
                color: _score >= widget.totalQuestions / 2 ? Colors.amber : Colors.blueAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _score >= widget.totalQuestions / 2
                    ? '🎉 أحسنت! عمل رائع!'
                    : '😊 لا بأس! حاول مرة أخرى',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // Replay button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF8674F5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context).retry,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            // Exit button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // exit the game screen
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context).returnBack,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restartGame() async {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _showFeedback = false;
      _isDropped = false;
      _selectedDirection = '';
      _remainingAttempts = 2;
    });

    // Reset SharedPreferences for this game
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, 0);
      await prefs.setInt(scoreKey!, 0);
    }

    // Reshuffle questions and images for new game
    questionDirections.shuffle();
    questionImages.shuffle();

    _startTimer();
  }

  bool isCorrectDirection(String selectedDirection) {
    return selectedDirection == questionDirections[_currentQuestionIndex % questionDirections.length];
  }

  void _listenAgain() {
    if (_remainingAttempts > 0) {
      setState(() {
        _remainingAttempts--;
      });
      final direction = questionDirections[_currentQuestionIndex % questionDirections.length];
      final meaning = directionData[direction]?['meaning'] ?? '';
      final imageType = questionImages[_currentQuestionIndex % questionImages.length]['name'];
      flutterTts.speak("ضع $imageType في الاتجاه $meaning");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF8674F5),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20; // Adjust for better positioning
    final radius = size.width * 0.35; // Radius of the circle

    // Calculate positions in a circle based on fixed angles
    if (directionPositions.isEmpty) {
      directionData.forEach((directionSymbol, data) {
        // Convert to double safely
        final angle = (data['angle'] is int)
            ? (data['angle'] as int).toDouble()
            : data['angle'] as double;
        double x = centerX + radius * math.cos(angle);
        double y = centerY + radius * math.sin(angle);
        directionPositions[directionSymbol] = Offset(x, y);
      });
    }

    // Get current direction and image
    String currentDirection = '';
    Map<String, dynamic> currentImage = {};

    if (questionDirections.isNotEmpty && questionDirections.length > 0) {
      // Make sure to use modulo to handle index
      int index = _currentQuestionIndex % questionDirections.length;
      currentDirection = questionDirections[index];
    }

    if (questionImages.isNotEmpty && questionImages.length > 0) {
      // Make sure to use modulo to handle index
      int index = _currentQuestionIndex % questionImages.length;
      currentImage = questionImages[index];
    }

    // Safely get meaning with null check
    final currentMeaning = directionData[currentDirection]?['meaning'] ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF8674F5),
        body: SafeArea(
          child: Column(
            children: [
              // Header with back button, title, and timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              title: Text(S.of(context).exitExerciseQuestion),
                              content: Text(S.of(context).progressWillBeLost),
                              actions: [
                                TextButton(
                                  child: Text(S.of(context).cancel),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text(S.of(context).exit),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        S.of(context).gameName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the close button
                  ],
                ),
              ),

              // Progress and timer section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السؤال ${_currentQuestionIndex + 1} / ${widget.totalQuestions}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            S.of(context).secondsRemaining(_timeLeft),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / widget.totalQuestions,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ),

              // Main game area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Title and instruction
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              S.of(context).whatIsDirection,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4FF),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFFE0E7FF)),
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    if (currentImage['name'] != null && currentMeaning.isNotEmpty) ...[
                                      TextSpan(text: 'اسحب ${currentImage['name']} إلى الاتجاه '),
                                      TextSpan(
                                        text: currentMeaning,
                                        style: const TextStyle(
                                            color: Colors.blue, // You can use any highlight color
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),
                                      ),
                                    ] else ...[
                                      TextSpan(text: S.of(context).dragInfo),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Display ALL direction circles with DragTargets
                      ...directionData.entries.map((entry) {
                        final pos = directionPositions[entry.key];
                        if (pos == null) return const SizedBox.shrink();  // Skip if position is null

                        // Check if this is the correct direction for highlighting
                        final isCorrectDirection = entry.key == currentDirection;

                        // Get color with safe type handling
                        Color bgColor;
                        Color borderColor;

                        try {
                          bgColor = _showFeedback && isCorrectDirection
                              ? Colors.green.withOpacity(0.2)
                              : (entry.value['color'] is Color
                              ? entry.value['color'] as Color
                              : const Color(0xFFE0E7FF));

                          borderColor = _showFeedback && isCorrectDirection
                              ? Colors.green
                              : (entry.value['borderColor'] is Color
                              ? entry.value['borderColor'] as Color
                              : const Color(0xFF6366F1));

                        } catch (e) {
                          // Fallback colors if there's any issue
                          bgColor = const Color(0xFFE0E7FF);
                          borderColor = const Color(0xFF6366F1);
                        }

                        return Positioned(
                          left: pos.dx - 60, // increase padding
                          top: pos.dy - 60,
                          child: SizedBox(
                            width: 120, // larger hit area
                            height: 120,
                            child: Center(
                              child: DragTarget<String>(
                                key: dropTargetKeys[entry.key],
                                hitTestBehavior: HitTestBehavior.opaque,
                                builder: (context, candidateData, rejectedData) {
                                  final isTargeted = candidateData.isNotEmpty;

                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: isTargeted
                                          ? const Color(0xFF8674F5).withOpacity(0.2)
                                          : bgColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isTargeted
                                            ? const Color(0xFF8674F5)
                                            : borderColor,
                                        width: isTargeted ? 3 : 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onWillAccept: (data) => !_isDropped && data == 'image',
                                onAccept: (data) {
                                  if (_isDropped) return;
                                  setState(() {
                                    _isDropped = true;
                                    _selectedDirection = entry.key;
                                    _timer.cancel();
                                  });
                                  final isCorrect = entry.key == questionDirections[_currentQuestionIndex % questionDirections.length];
                                  _showAnswer(isCorrect);
                                },
                              ),
                            ),
                          ),
                        );
                      }),

                      // Draggable image in the center - IMPROVED IMPLEMENTATION
                      // Draggable image in the center - Optimized
                      if (!_isDropped && currentImage.isNotEmpty)
                        Positioned(
                          left: centerX - 45,
                          top: centerY - 45,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              final Widget draggableContent = Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8674F5),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        currentImage['icon'] as IconData,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentImage['name'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              return Draggable<String>(
                                data: 'image',
                                dragAnchorStrategy: childDragAnchorStrategy,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: draggableContent, // Same as child
                                ),
                                childWhenDragging: const SizedBox(width: 90, height: 90),

                                // ✅ REMOVE feedbackOffset or set it to Offset.zero
                                feedbackOffset: Offset.zero,

                                maxSimultaneousDrags: 1,
                                onDragStarted: () {},
                                onDragEnd: (details) {
                                  if (!_isDropped) {
                                    // Handle if needed
                                  }
                                },
                                onDraggableCanceled: (velocity, offset) {}, // ✅ Centers under touch/click
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: draggableContent,
                                ),
                              );
                            },
                          ),
                        ),


                      // Listen again button
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _remainingAttempts > 0
                                  ? const Color(0xFF8674F5)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _remainingAttempts > 0 ? _listenAgain : null,
                            icon: const Icon(Icons.volume_up, color: Colors.white),
                            label: Text(
                              S.of(context).listenAgain(_remainingAttempts),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Feedback overlay
                      if (_showFeedback)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              width: size.width * 0.85,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: _isCorrect ? Colors.green : Colors.red,
                                    size: 80,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isCorrect? S.of(context).correct : S.of(context).incorrect,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  if (!_isCorrect) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      S.of(context).correctAnswerIs(currentMeaning),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  // 🎯 Motivational or Celebration Message
                                  Builder(
                                    builder: (_) {
                                      final messageData = _isCorrect
                                          ? _getRandomCelebrationMessage()
                                          : _getRandomMotivationalMessage();
                                      return Column(
                                        children: [
                                          Text(
                                            messageData['emoji'],
                                            style: const TextStyle(fontSize: 40),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            messageData['message'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}