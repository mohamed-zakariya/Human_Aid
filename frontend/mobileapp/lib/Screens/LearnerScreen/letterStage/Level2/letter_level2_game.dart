import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileapp/models/letter.dart';
import '../../../../Services/add_score_service.dart';
import '../../../../Services/letters_service.dart';
import '../../../../generated/l10n.dart';

import '../letter_forms.dart';

// Colors list from your LetterLevel2Game class
const List<Color> colors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.amber,
  Colors.cyan,
];

class LetterLevel2Game extends StatefulWidget {
  const LetterLevel2Game({super.key});

  @override
  State<LetterLevel2Game> createState() => _LetterLevel2GameState();
}

class _LetterLevel2GameState extends State<LetterLevel2Game> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Letter> allLetters = [];
  bool isLoading = true;

  static const int totalRounds = 10;
  int currentRound = 0;
  int score = 0;

  // SharedPreferences keys and values
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? roundKey;
  String? scoreKey;
  String? levelGameId;

  List<Letter> currentOptions = [];
  List<Color> optionColors = [];
  late Letter targetLetter;
  String? selectedLetter;
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage('ar-SA'); // Set language to Arabic
    _flutterTts.setSpeechRate(0.5); // Adjust speech rate
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

      print("levelId" + levelId!);
      print("gameId" + gameId!);
      print("levelGameId" + levelGameId!);


      // Initialize round and score from SharedPreferences
      currentRound = prefs.getInt(roundKey!) ?? 1;
      score = prefs.getInt(scoreKey!) ?? 0;

      // Ensure currentRound is within bounds (1 to totalRounds)
      if (currentRound < 1) currentRound = 1;
      if (currentRound > totalRounds) currentRound = totalRounds;

      // Ensure score is within bounds (0 to totalRounds)
      if (score < 0) score = 0;
      if (score > totalRounds) score = totalRounds;
    }

    _loadLetters();
  }

  Future<void> _loadLetters() async {
    setState(() => isLoading = true);
    final fetchedLetters = await LettersService.getLettersForLevel1();
    if (fetchedLetters != null) {
      allLetters = fetchedLetters;
      _startNewRound();
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProgressToSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, currentRound);
      await prefs.setInt(scoreKey!, score);
    }
  }

  void _startNewRound() {
    if (currentRound > totalRounds) {
      _showGameOverDialog();
      return;
    }

    final random = Random();
    final shuffledLetters = [...allLetters]..shuffle();
    currentOptions = shuffledLetters.take(10).toList();
    targetLetter = currentOptions[random.nextInt(10)];
    selectedLetter = null;
    showFeedback = false;

    final shuffledColors = [...colors]..shuffle(random);
    optionColors = shuffledColors.take(10).toList();

    setState(() {});

    // 🔊 Speak the letter after a brief delay to ensure TTS is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      _flutterTts.setLanguage('ar'); // Ensure Arabic language
      _flutterTts.speak(targetLetter.letter);
    });
  }

  void _checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      showFeedback = true;
      if (letter == targetLetter.letter) {
        score++;
      }
    });


    // Save progress after each answer
    _saveProgressToSharedPreferences();
  }

  void _showGameOverDialog() async {
    // Send the scaled score (out of totalRounds)
    await AddScoreService.updateScore(
      score: score,
      outOf: totalRounds,
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
              score >= 8 ? Icons.emoji_events : Icons.sentiment_satisfied,
              size: 64,
              color: score >= 8 ? Colors.amber : Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              score >= 8
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
      currentRound = 1;
      score = 0;
    });

    // Reset SharedPreferences for this game
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, 1);
      await prefs.setInt(scoreKey!, 0);
    }

    _startNewRound();
  }

  void _showHelpDialog() {
    final String lang = Localizations.localeOf(context).languageCode;

    (lang == 'en')? _flutterTts.setLanguage('en'):_flutterTts.setLanguage('ar');

    final String title = lang == 'en' ? 'How to Play 🎯' : 'طريقة اللعب 🎯';
    final String contentText = lang == 'en'
        ? '1️⃣ Tap the "Listen to the letter" button to hear the target letter.\n\n'
        '2️⃣ Choose the correct letter from the colorful options.\n\n'
        '3️⃣ You earn a point for each correct answer. Score more than 8 to win!'
        : '1️⃣ اضغط على زر "استمع إلى الحرف" لسماع الحرف المطلوب.\n\n'
        '2️⃣ اختر الحرف الصحيح من بين الخيارات الملونة.\n\n'
        '3️⃣ تحصل على نقطة لكل إجابة صحيحة. اجمع أكثر من 8 للفوز!';

    final String ttsText = lang == 'en'
        ? '1. Tap the "Listen to the letter" button to hear the target letter. '
        '2. Choose the correct letter from the colorful options. '
        '3. You earn a point for each correct answer. Score more than 8 to win!'
        : '1 اضغط على زر "استمع إلى الحرف" لسماع الحرف المطلوب. '
        '2 اختر الحرف الصحيح من بين الخيارات الملونة. '
        '3 تحصل على نقطة لكل إجابة صحيحة. اجمع أكثر من 8 للفوز!';

    final String listenLabel = lang == 'en' ? 'Listen to Instructions' : 'استمع للتعليمات';
    final String okLabel = lang == 'en' ? 'OK' : 'حسنًا';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentText,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: lang == 'en' ? TextAlign.left : TextAlign.right,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _flutterTts.speak(ttsText);
              },
              icon: const Icon(Icons.volume_up, size: 28),
              label: Text(listenLabel, style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _flutterTts.stop();
              Navigator.pop(context);
            },
            child: Text(okLabel, style: const TextStyle(fontSize: 16)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Widget _buildLetterButton(String letter, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: selectedLetter == null ? () => _checkAnswer(letter) : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated game UI with purple theme
  Widget _buildGameUI() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      children: [
        // Purple Header
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF6E5DE7), // Purple color from screenshot
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
        ),

        Expanded(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Round text
                  Builder(builder: (context) {
                    final lang = Localizations.localeOf(context).languageCode;
                    return Text(
                      lang == 'en'
                          ? 'Round $currentRound of $totalRounds'
                          : 'الجولة $currentRound من $totalRounds',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Listen button
                  Builder(builder: (context) {
                    final lang = Localizations.localeOf(context).languageCode;
                    return ElevatedButton.icon(
                      onPressed: () => {
                        _flutterTts.setLanguage('ar'),
                        _flutterTts.speak(targetLetter.letter)
                      },
                      icon: const Icon(Icons.volume_up, size: 28),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          lang == 'en' ? 'Listen to the letter' : 'استمع إلى الحرف',
                          style: TextStyle(fontSize: isTablet ? 20 : 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.builder(
                      itemCount: currentOptions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (context, index) {
                        final letter = currentOptions[index].letter;
                        final color = optionColors[index];
                        return _buildLetterButton(letter, color);
                      },
                    ),
                  ),

                  if (showFeedback)
                    Builder(builder: (context) {
                      final lang = Localizations.localeOf(context).languageCode;
                      final isCorrect = selectedLetter == targetLetter.letter;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isCorrect
                              ? (lang == 'en' ? '🎉 Correct!' : '🎉 صحيح!')
                              : (lang == 'en'
                              ? '❌ Wrong, correct is: ${targetLetter.letter}'
                              : '❌ خطأ، الصحيح: ${targetLetter.letter}'),
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }),

                  if (showFeedback)
                    Builder(builder: (context) {
                      final lang = Localizations.localeOf(context).languageCode;
                      return ElevatedButton(
                        onPressed: () {
                          currentRound++;
                          _saveProgressToSharedPreferences();
                          _startNewRound();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: Size(isTablet ? 250 : 180, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(lang == 'en' ? 'Next' : 'التالي'),
                      );
                    }),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF6E5DE7),
          centerTitle: true,
          title: Text(args['gameName']),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              tooltip: 'مساعدة',
              onPressed: _showHelpDialog,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildGameUI()
    );
  }
}