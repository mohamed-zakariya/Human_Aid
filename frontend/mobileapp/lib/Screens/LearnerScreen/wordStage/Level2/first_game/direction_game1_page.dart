import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Services/add_score_service.dart';
import '../../../../../generated/l10n.dart';

class DirectionGamePage extends StatefulWidget {
  final int totalQuestions;

  const DirectionGamePage({Key? key, this.totalQuestions = 10}) : super(key: key);

  @override
  _DirectionGamePageState createState() => _DirectionGamePageState();
}

class _DirectionGamePageState extends State<DirectionGamePage> {

  int correctAnswers = 0;

  final FlutterTts flutterTts = FlutterTts();
  final directions = ['↑', '↓', '→', '←', '↗', '↘', '↖', '↙'];
  final directionLabels = {
    '↑': 'أعلى',
    '↓': 'أسفل',
    '→': 'يمين',
    '←': 'يسار',
    '↗': 'أعلى اليمين',
    '↘': 'أسفل اليمين',
    '↖': 'أعلى اليسار',
    '↙': 'أسفل اليسار',
  };

  final encouragingMessages = [
    "ممتاز! 🎉",
    "رائع! 👍",
    "استمر! 💪",
    "أنت متألق! 🔥",
    "عمل رائع! 🌟",
    "براڤو! 👏",
    "مذهل! 😎",
    "أحسنت! 🥳",
  ];

  final motivationalMessages = [
    "حاول مرة أخرى! 💪",
    "لا بأس، استمر! 👍",
    "يمكنك فعلها! ✨",
    "لا تستسلم! 🌟",
    "أنت تتحسن! 📈",
    "المحاولة التالية ستكون أفضل! 🔄",
    "استمر في المحاولة! 🚀",
  ];

  // SharedPreferences keys and values
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? roundKey;
  String? scoreKey;
  String? levelGameId;

  late String currentDirection;
  int questionIndex = 0;
  int timeLeft = 5;
  Timer? timer;
  bool showFeedback = false;
  String feedbackText = '';
  String encouragingText = '';
  int listenAttemptsRemaining = 2;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initTts();
    _initializeFromSharedPreferences();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
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
      questionIndex = prefs.getInt(roundKey!) ?? 1; // Start from 0
      correctAnswers = prefs.getInt(scoreKey!) ?? 0;

      // Ensure questionIndex is within bounds (0 to totalQuestions-1)
      if (questionIndex < 0) questionIndex = 0;
      if (questionIndex >= widget.totalQuestions) questionIndex = widget.totalQuestions - 1;

      // Ensure correctAnswers is within bounds (0 to totalQuestions)
      if (correctAnswers < 0) correctAnswers = 0;
      if (correctAnswers > widget.totalQuestions) correctAnswers = widget.totalQuestions;
    }

    setState(() {
      isLoading = false;
    });

    // Load the first/current question without incrementing
    loadCurrentQuestion();
  }

  Future<void> _saveProgressToSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, questionIndex);
      await prefs.setInt(scoreKey!, correctAnswers);
    }
  }

  // List to store randomized options for current question
  List<String> currentOptions = [];

  void nextQuestion() {
    // Increment to move to next question
    questionIndex++;

    // Save progress after incrementing
    _saveProgressToSharedPreferences();

    // Load the new question
    loadCurrentQuestion();
  }

  // Generate random options for each question
  List<String> generateRandomOptions(String correctDirection) {
    // Always include the correct answer
    final correctAnswer = directionLabels[correctDirection]!;

    // Create a list of all possible answers except the correct one
    final possibleAnswers = directionLabels.values.toList()
      ..remove(correctAnswer);

    // Shuffle the possible answers
    possibleAnswers.shuffle();

    // Take the first 3 wrong answers and add the correct one
    final result = possibleAnswers.take(3).toList()..add(correctAnswer);

    // Shuffle again to randomize the position of the correct answer
    result.shuffle();

    return result;
  }

  Future<void> speakQuestion() async {
    String arabicDirection = directionLabels[currentDirection]!;
    await flutterTts.speak("ما هو الاتجاه $arabicDirection");
  }

  void tryListenAgain() {
    if (listenAttemptsRemaining > 0) {
      setState(() {
        listenAttemptsRemaining--;
      });
      speakQuestion();
    }
  }

  void loadCurrentQuestion() {
    if (questionIndex >= widget.totalQuestions) {
      _showGameOverDialog();
      return;
    }

    setState(() {
      // Select a random direction as the answer
      currentDirection = directions[Random().nextInt(directions.length)];

      // Generate 4 unique random options (including the correct answer)
      currentOptions = generateRandomOptions(currentDirection);

      timeLeft = 5;
      showFeedback = false;
      listenAttemptsRemaining = 2;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        showResultFeedback(false);
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void showResultFeedback(bool correct) {
    setState(() {
      showFeedback = true;
      if (correct) {
        feedbackText = S.of(context).correct;
        encouragingText = encouragingMessages[Random().nextInt(encouragingMessages.length)];
      } else {
        feedbackText = S.of(context).incorrect;
        encouragingText = "${motivationalMessages[Random().nextInt(motivationalMessages.length)]}\nالإجابة الصحيحة: ${directionLabels[currentDirection]}";
      }
    });

    // Speak the feedback
    flutterTts.speak(correct ? encouragingText : "${motivationalMessages[Random().nextInt(motivationalMessages.length)]}\n${S.of(context).correctAnswerIs(directionLabels[currentDirection]!)}",);

    timer?.cancel();
    Future.delayed(const Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  void checkAnswer(String selectedDirection) {
    bool correct = selectedDirection == directionLabels[currentDirection];

    if (correct) {
      correctAnswers++; // Track correct answers
    }

    // Stop current timer
    timer?.cancel();

    // Show overlay feedback
    setState(() {
      showFeedback = true;
      if (correct) {
        feedbackText = "صحيح! ✅";
        encouragingText = encouragingMessages[Random().nextInt(encouragingMessages.length)];
      } else {
        feedbackText = "خطأ! ❌";
        encouragingText = "${motivationalMessages[Random().nextInt(motivationalMessages.length)]}\nالإجابة الصحيحة: ${directionLabels[currentDirection]}";
      }
    });

    // Speak the feedback
    flutterTts.speak(correct ? "إجابة صحيحة" : "إجابة خاطئة");

    // Go to next question after delay
    Future.delayed(const Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  void _showGameOverDialog() async {
    // Submit scaled score out of totalQuestions
    await AddScoreService.updateScore(
      score: correctAnswers,
      outOf: widget.totalQuestions,
    );

    // Clear the saved progress since game is completed
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(roundKey!);
      await prefs.remove(scoreKey!);
    }

    final lang = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Center(
          child: Text(
            lang == 'en' ? '🎮 Game Over' : '🎮 انتهت اللعبة',
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
              correctAnswers >= 8 ? Icons.emoji_events : Icons.sentiment_satisfied,
              size: 64,
              color: correctAnswers >= 8 ? Colors.amber : Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              correctAnswers >= 8
                  ? (lang == 'en'
                  ? '🎉 Well done! Great job!'
                  : '🎉 أحسنت! عمل رائع!')
                  : (lang == 'en'
                  ? '😊 Not bad! Try again.'
                  : '😊 لا بأس! حاول مرة أخرى'),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'en'
                  ? 'Score: $correctAnswers/${widget.totalQuestions}'
                  : 'النتيجة: $correctAnswers/${widget.totalQuestions}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              lang == 'en' ? 'Play Again' : 'إعادة اللعب',
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
              lang == 'en' ? 'Exit' : 'الخروج',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() async {
    setState(() {
      questionIndex = 0;
      correctAnswers = 0;
      isLoading = false;
    });

    // Reset SharedPreferences for this game
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, 0);
      await prefs.setInt(scoreKey!, 0);
    }

    nextQuestion();
  }

  @override
  void dispose() {
    timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF7367F0),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF7367F0),
      appBar: AppBar(
        backgroundColor: Color(0xFF7367F0),
        elevation: 0,
        title: Text(
          S.of(context).directionExerciseTitle,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress and Timer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).seconds(timeLeft),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  S.of(context).questionProgress(questionIndex, widget.totalQuestions),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: questionIndex / widget.totalQuestions,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Main content with white background
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Question
                    Text(
                      S.of(context).whatIsDirection,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    // Direction Symbol Display
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF7367F0).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          currentDirection,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7367F0),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Listen Again Button with remaining attempts
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton.icon(
                        onPressed: listenAttemptsRemaining > 0 ? tryListenAgain : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: listenAttemptsRemaining > 0
                              ? Color(0xFF7367F0)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          S.of(context).listenAgain(listenAttemptsRemaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Feedback display if active
                    if (showFeedback) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: feedbackText.contains("✅")
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              feedbackText,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: feedbackText.contains("✅")
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              encouragingText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Direction options - now showing only Arabic words with randomized options
                    if (!showFeedback) ...[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 30,
                            ),
                            itemCount: currentOptions.length,
                            itemBuilder: (context, index) {
                              final optionText = currentOptions[index];
                              return GestureDetector(
                                onTap: () => checkAnswer(optionText),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF7367F0),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF7367F0).withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}