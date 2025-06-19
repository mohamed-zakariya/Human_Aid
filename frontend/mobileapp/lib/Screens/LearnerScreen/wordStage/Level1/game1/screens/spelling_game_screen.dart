import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Import TTS service
import 'package:mobileapp/Services/tts_service.dart';

import '../../../../../../Services/add_score_service.dart';
import '../../../../../../Services/word_service_second_part.dart';
import '../widgets/help_sheet.dart';
import '../widgets/letter_slot.dart';
import '../widgets/letter_title.dart';
import '../widgets/synonym_section.dart';

// Localization class
class AppLocalizations {
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'spelling_game': 'Spelling Game',
      'question': 'Question',
      'game_finished': 'Game Finished!',
      'your_score': 'Your Score',
      'play_again': 'Play Again',
      'exit_game': 'Exit Game',
      'listen_to_word': 'Listen to the word',
      'excellent': 'Excellent!',
      'very_good': 'Very Good!',
      'good_job': 'Good Job!',
      'keep_trying': 'Keep Trying!',
      'try_again': 'Try Again!',
      'correct_answer': 'Correct Answer!',
      'wrong_answer': 'Wrong Answer!',
      'next_round': 'Next Round',
      'final_round': 'Final Round',
      'congratulations': 'Congratulations!',
      'perfect_score': 'Perfect Score!',
      'great_effort': 'Great Effort!',
      'instructions': 'Instructions',
      'drag_letters': 'Drag letters to spell the word shown in the image',
      'choose_synonym': 'Then choose the correct synonym from the options below',
      'loading_words': 'Loading words...',
      'error_loading_words': 'Error loading words. Please try again.',
      'loading_next_round': 'Loading next round...',
      'preparing_round': 'Preparing round...',
    },
    'ar': {
      'spelling_game': 'لعبة التهجئة',
      'question': 'السؤال',
      'game_finished': 'انتهت اللعبة!',
      'your_score': 'نتيجتك',
      'play_again': 'العب مرة أخرى',
      'exit_game': 'خروج من اللعبة',
      'listen_to_word': 'استمع إلى الكلمة',
      'excellent': 'ممتاز!',
      'very_good': 'جيد جداً!',
      'good_job': 'أحسنت!',
      'keep_trying': 'استمر في المحاولة!',
      'try_again': 'حاول مرة أخرى!',
      'correct_answer': 'إجابة صحيحة!',
      'wrong_answer': 'إجابة خاطئة!',
      'next_round': 'الجولة التالية',
      'final_round': 'الجولة الأخيرة',
      'congratulations': 'مبروك!',
      'perfect_score': 'علامة كاملة!',
      'great_effort': 'مجهود عظيم!',
      'instructions': 'التعليمات',
      'drag_letters': 'اسحب الحروف لتهجئة الكلمة الموضحة في الصورة',
      'choose_synonym': 'ثم اختر المرادف الصحيح من الخيارات أدناه',
      'loading_words': 'جاري تحميل الكلمات...',
      'error_loading_words': 'خطأ في تحميل الكلمات. يرجى المحاولة مرة أخرى.',
      'loading_next_round': 'جاري تحميل الجولة التالية...',
      'preparing_round': 'جاري تحضير الجولة...',
    },
  };

  static String translate(String key, String locale) {
    return _localizedValues[locale]?[key] ?? key;
  }
}

// Updated WordModel to work with the new service
class WordModel {
  final String word;
  final String image;
  final List<String> synonymChoices;
  final String correctSynonym;

  WordModel({
    required this.word,
    required this.image,
    required this.synonymChoices,
    required this.correctSynonym,
  });

  // Factory constructor to create from GameWords
  factory WordModel.fromGameWords(GameWords gameWords) {
    return WordModel(
      word: gameWords.mainWord.word,
      image: gameWords.mainWord.imageUrl,
      synonymChoices: gameWords.synonymChoices.map((w) => w.word).toList(),
      correctSynonym: gameWords.mainWord.word, // The main word is the correct answer
    );
  }
}

// Main Game Screen
class SpellingGameScreen extends StatefulWidget {
  final String level;

  const SpellingGameScreen(this.level, {super.key});

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen> with TickerProviderStateMixin {
  // Audio players for different sound effects
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _dropPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final TTSService ttsService = TTSService();

  // Localization
  String currentLocale = 'ar'; // Default to Arabic since this is for Arabic practice

  // SharedPreferences keys and values
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? roundKey;
  String? scoreKey;
  String? levelGameId;

  // Game state - Changed to single round approach
  WordModel? currentWordModel;
  WordModel? nextWordModel; // Preload next round
  bool isLoadingCurrentWord = true;
  bool isLoadingNextWord = false;
  String? errorMessage;

  int totalRounds = 10; // Add this to your class variables (same as maxRounds)
  int currentRound = 0;
  int totalScore = 0;
  int maxRounds = 10; // Set a maximum number of rounds or make it configurable
  List<String?> selectedLetters = [];
  late List<String> shuffledLetters;
  bool isCorrect = false;
  bool showFullWord = false;
  bool showSynonymSection = false;
  String? droppedSynonym;
  bool synonymMatched = false;
  bool roundCompleted = false;
  bool isSpellingComplete = false;

  // Timer variables
  int timeLeft = 20; // 20 seconds per round
  Timer? gameTimer;
  bool timerActive = false;

  late final AnimationController _synonymSectionController;
  late final AnimationController _nextButtonController;
  late final AnimationController _successAnimationController;
  late final AnimationController _motivationController;

  @override
  void initState() {
    super.initState();

    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _synonymSectionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _nextButtonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _motivationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize sound effects
    _initSoundEffects();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _initializeFromSharedPreferences();
    await _loadCurrentRoundWord();
  }

  Future<WordModel> _loadWordFromService() async {
    try {
      // Get single game word for current round
      final gameWordsList = await WordsService.getMultipleGameWords(widget.level, 1);

      if (gameWordsList == null || gameWordsList.isEmpty) {
        throw Exception('No words available');
      }

      return WordModel.fromGameWords(gameWordsList.first);
    } catch (e) {
      print('Error loading word: $e');
      throw e;
    }
  }

  Future<void> _loadCurrentRoundWord() async {
    if (currentRound >= maxRounds) {
      _showCompletionDialog();
      return;
    }

    try {
      setState(() {
        isLoadingCurrentWord = true;
        errorMessage = null;
      });

      final wordModel = await _loadWordFromService();

      if (mounted) { // Check if widget is still mounted
        setState(() {
          currentWordModel = wordModel;
          isLoadingCurrentWord = false;
        });

        _setupRound();
        _preloadNextWord();
      }
    } catch (e) {
      print('Error loading current round word: $e');
      if (mounted) {
        setState(() {
          errorMessage = AppLocalizations.translate('error_loading_words', currentLocale);
          isLoadingCurrentWord = false;
        });
      }
    }
  }

  Future<void> _preloadNextWord() async {
    if (currentRound >= maxRounds - 1) return; // Don't preload if this is the last round

    try {
      setState(() {
        isLoadingNextWord = true;
      });

      final wordModel = await _loadWordFromService();

      setState(() {
        nextWordModel = wordModel;
        isLoadingNextWord = false;
      });
    } catch (e) {
      print('Error preloading next word: $e');
      setState(() {
        isLoadingNextWord = false;
      });
    }
  }

  Future<void> _initializeFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the stored IDs from SharedPreferences
    exerciseId = prefs.getString('exerciseId');
    levelId = prefs.getString('levelId');
    learnerId = prefs.getString('learnerId');
    gameId = prefs.getString('gameId');
    levelGameId = prefs.getString('levelGameId');
    print("mmmmmmmmmmmmmmmm");
    print(levelGameId);
    print(gameId);

    if (levelId != null && gameId != null) {
      // Create keys for this specific level and game
      roundKey = '${levelId}_${gameId}_${levelGameId}_round';
      scoreKey = '${levelId}_${gameId}_${levelGameId}_score';

      // Initialize round and score from SharedPreferences
      currentRound = prefs.getInt(roundKey!) ?? 0;
      totalScore = prefs.getInt(scoreKey!) ?? 0;

      // Ensure currentRound is within bounds
      if (currentRound < 0) currentRound = 0;
      if (currentRound >= maxRounds) currentRound = maxRounds - 1;

      // Ensure score is within bounds
      if (totalScore < 0) totalScore = 0;
      if (totalScore > maxRounds * 2) totalScore = maxRounds * 2;
    }
  }

  Future<void> _saveProgressToSharedPreferences() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, currentRound);
      await prefs.setInt(scoreKey!, totalScore);
      print('Progress saved: Round $currentRound, Score $totalScore'); // Add for debugging
    }
  }

  Future<void> _initSoundEffects() async {
    try {
      await _correctPlayer.setSource(AssetSource('sounds/correct.wav'));
      await _incorrectPlayer.setSource(AssetSource('sounds/incorrect.wav'));
      await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
      await _dropPlayer.setSource(AssetSource('sounds/drop.wav'));
      await _successPlayer.setSource(AssetSource('sounds/success.wav'));
    } catch (e) {
      print('Error initializing sounds: $e');
    }

    // Initialize TTS service
    await ttsService.initialize(language: "ar-EG");
  }

  Future<void> _playSound(AudioPlayer player) async {
    try {
      await player.stop();
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      print('Error playing sound: $e');
      // Try alternative approach
      try {
        await player.play(player.source!);
      } catch (e2) {
        print('Alternative sound play failed: $e2');
      }
    }
  }

  @override
  void dispose() {
    // Stop timer
    gameTimer?.cancel();

    // Dispose audio players
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _clickPlayer.dispose();
    _dropPlayer.dispose();
    _successPlayer.dispose();

    // Stop any TTS and dispose
    ttsService.stop();

    // Dispose animation controllers
    _synonymSectionController.dispose();
    _nextButtonController.dispose();
    _successAnimationController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _setupRound() {
    if (currentWordModel == null) return;

    // Cancel existing timer first
    gameTimer?.cancel();
    timerActive = false;

    final word = currentWordModel!.word;

    shuffledLetters = word.split('')..shuffle(Random());
    selectedLetters = List.filled(word.length, null);
    isCorrect = false;
    showFullWord = false;
    showSynonymSection = false;
    droppedSynonym = null;
    synonymMatched = false;
    roundCompleted = false;
    isSpellingComplete = false;

    // Reset timer
    timeLeft = 20;
    _startTimer();

    _successAnimationController.reset();
    _synonymSectionController.reset();
    _nextButtonController.reset();
    _motivationController.reset();

    setState(() {});
  }

  void _startTimer() {
    gameTimer?.cancel();
    timerActive = true;

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (roundCompleted) {
        timer.cancel();
        timerActive = false;
        return;
      }

      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          timerActive = false;
          _timeUp();
        }
      });
    });
  }

  void _timeUp() {
    _playSound(_incorrectPlayer);

    setState(() {
      roundCompleted = true;
    });

    _motivationController.forward();

    // Save progress before showing dialog
    _saveProgressToSharedPreferences();

    // Show time up dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      _showMotivationDialog(false, isTimeUp: true);
    });
  }

  void _checkSpelling() {
    if (currentWordModel == null) return;

    final userAnswer = selectedLetters.join();
    final correctWord = currentWordModel!.word;

    if (userAnswer == correctWord) {
      _playSound(_correctPlayer);
      ttsService.speak(correctWord);

      setState(() {
        isCorrect = true;
        showFullWord = true;
        showSynonymSection = true;
        isSpellingComplete = true;
      });

      _successAnimationController.forward();
      _synonymSectionController.forward();
    } else {
      _playSound(_incorrectPlayer);

      // Reset slots if answer is incorrect
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          selectedLetters = List.filled(correctWord.length, null);
        });
      });
    }
  }

  void _onSynonymDropped(String choice) {
    if (currentWordModel == null || roundCompleted) return;

    final correct = currentWordModel!.correctSynonym;

    _playSound(_dropPlayer);

    setState(() {
      droppedSynonym = choice;
      synonymMatched = choice == correct;

      if (synonymMatched) {
        _playSound(_successPlayer);
        totalScore += 2; // 1 for spelling + 1 for synonym
        _completeRound(true);
      } else {
        _playSound(_incorrectPlayer);
        totalScore += 1; // Only 1 for spelling
        _completeRound(false);
      }
    });
  }

  void _completeRound(bool synonymCorrect) {
    gameTimer?.cancel();
    timerActive = false;

    setState(() {
      roundCompleted = true;
    });

    _motivationController.forward();

    // Save progress after completing round
    _saveProgressToSharedPreferences();

    // Show motivation dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      _showMotivationDialog(synonymCorrect);
    });
  }


  

  void _showMotivationDialog(bool synonymCorrect, {bool isTimeUp = false}) {
    String motivation;
    String emoji;
    Color backgroundColor;

    if (isTimeUp) {
      motivation = _getRandomMotivation(['keep_trying', 'try_again']);
      emoji = '⏰';
      backgroundColor = Colors.red.shade100;
    } else if (isSpellingComplete && synonymCorrect) {
      motivation = _getRandomMotivation(['excellent', 'perfect_score', 'congratulations']);
      emoji = '🎉';
      backgroundColor = Colors.green.shade100;
    } else if (isSpellingComplete) {
      motivation = _getRandomMotivation(['good_job', 'very_good', 'great_effort']);
      emoji = '👍';
      backgroundColor = Colors.orange.shade100;
    } else {
      motivation = _getRandomMotivation(['keep_trying', 'try_again']);
      emoji = '💪';
      backgroundColor = Colors.blue.shade100;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: backgroundColor,
        title: Text(
          "$emoji $motivation",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              "${AppLocalizations.translate('question', currentLocale)} ${currentRound + 1} / $maxRounds",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _playSound(_clickPlayer);
                Navigator.pop(context);
                _nextRound();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F73FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: isLoadingNextWord
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                currentRound < maxRounds - 1
                    ? AppLocalizations.translate('next_round', currentLocale)
                    : AppLocalizations.translate('final_round', currentLocale),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRandomMotivation(List<String> keys) {
    final randomKey = keys[Random().nextInt(keys.length)];
    return AppLocalizations.translate(randomKey, currentLocale);
  }

  void _nextRound() async {
    if (currentRound < maxRounds - 1) {
      setState(() {
        currentRound++;
      });
      await _saveProgressToSharedPreferences();

      // Use preloaded word if available, otherwise load new one
      if (nextWordModel != null) {
        setState(() {
          currentWordModel = nextWordModel;
          nextWordModel = null;
        });
        _setupRound();
        // Preload next word in background
        _preloadNextWord();
      } else {
        // Fallback: load current round word if preloading failed
        await _loadCurrentRoundWord();
      }
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() async {
    _playSound(_successPlayer);

    // Submit score to backend
    await AddScoreService.updateScore(
      score: totalScore,
      outOf: maxRounds * 2, // Max 2 points per round
    );

    // Clear the saved progress since game is completed
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(roundKey!);
      await prefs.remove(scoreKey!);
    }

    String finalMotivation;
    String emoji;
    double percentage = (totalScore / (maxRounds * 2)) * 100;

    if (percentage >= 90) {
      finalMotivation = AppLocalizations.translate('perfect_score', currentLocale);
      emoji = '🏆';
    } else if (percentage >= 70) {
      finalMotivation = AppLocalizations.translate('excellent', currentLocale);
      emoji = '⭐';
    } else if (percentage >= 50) {
      finalMotivation = AppLocalizations.translate('good_job', currentLocale);
      emoji = '👏';
    } else {
      finalMotivation = AppLocalizations.translate('great_effort', currentLocale);
      emoji = '💪';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "$emoji ${AppLocalizations.translate('game_finished', currentLocale)}",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(finalMotivation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Play Again Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _playSound(_clickPlayer);
                  Navigator.pop(context);
                  _restartGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F73FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  "🔁 ${AppLocalizations.translate('play_again', currentLocale)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Exit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _playSound(_clickPlayer);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit game
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  "🚪 ${AppLocalizations.translate('exit_game', currentLocale)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }



  void _restartGame() async {
    setState(() {
      currentRound = 0;
      totalScore = 0;
      currentWordModel = null;
      nextWordModel = null;
    });

    // Reset SharedPreferences for this game
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, 0);
      await prefs.setInt(scoreKey!, 0);
    }

    // Load first round
    await _loadCurrentRoundWord();
  }








  @override
  Widget build(BuildContext context) {
    currentLocale = Localizations.localeOf(context).languageCode;


    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Get locale from arguments if provided
    if (args != null && args.containsKey('locale')) {
      currentLocale = args['locale'];
    }

    // Show loading screen if no word is loaded yet
    if (isLoadingCurrentWord || currentWordModel == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _playSound(_clickPlayer);
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            args?['gameName'] ?? AppLocalizations.translate('spelling_game', currentLocale),
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF7F73FF),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7F73FF)),
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage ?? AppLocalizations.translate('loading_words', currentLocale),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _loadCurrentRoundWord();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F73FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final word = currentWordModel!.word;
    final image = currentWordModel!.image;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _playSound(_clickPlayer);
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          args?['gameName'] ?? AppLocalizations.translate('spelling_game', currentLocale),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF7F73FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              _playSound(_clickPlayer);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.translate('instructions', currentLocale),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.translate('drag_letters', currentLocale),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.translate('choose_synonym', currentLocale),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Purple header area
          Container(
            height: 80,
            width: double.infinity,
            color: const Color(0xFF7F73FF),
            child: Row(
              children: [
                // Question counter
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: "${AppLocalizations.translate('question', currentLocale)} "),
                            TextSpan(
                              text: "${currentRound + 1}",
                              style: const TextStyle(color: Colors.yellow, fontSize: 20),
                            ),
                            TextSpan(text: " / $totalRounds"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Timer
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: timeLeft <= 10 ? Colors.red.withOpacity(0.8) : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: timeLeft <= 10 ? Colors.white : Colors.yellow,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$timeLeft",
                        style: TextStyle(
                          color: timeLeft <= 10 ? Colors.white : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Letter slots - Always RTL direction like Arabic
                  Localizations.localeOf(context).languageCode == 'en'
                      ? Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(word.length, (index) {
                      return LetterSlot(
                        letter: selectedLetters[index],
                        onAccept: (data) {
                          setState(() {
                            selectedLetters[index] = data;
                            if (!selectedLetters.contains(null)) _checkSpelling();
                          });
                        },
                      );
                    }).reversed.toList(), // Reversed for RTL (Arabic, Hebrew, etc.)
                  )
                      : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(word.length, (index) {
                      return LetterSlot(
                        letter: selectedLetters[index],
                        onAccept: (data) {
                          setState(() {
                            selectedLetters[index] = data;
                            if (!selectedLetters.contains(null)) _checkSpelling();
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // Letter tiles
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: shuffledLetters.map((letter) {
                      int usedCount = selectedLetters.where((l) => l == letter).length;
                      int totalCount = shuffledLetters.where((l) => l == letter).length;

                      if (usedCount >= totalCount) return const SizedBox(width: 50, height: 50);

                      return LetterTile(letter: letter);
                    }).toList(),
                  ),

                  if (showFullWord) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          word,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F73FF),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          child: IconButton(
                            onPressed: () {
                              ttsService.setLanguage('ar-EG');
                              ttsService.speak(word);
                            },
                            icon: const Icon(Icons.volume_up, color: Color(0xFF7F73FF)),
                            tooltip: AppLocalizations.translate('listen_to_word', currentLocale),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // Synonym section
                  if (showSynonymSection)
                    SynonymSection(
                      choices: currentWordModel!.synonymChoices,
                      droppedSynonym: droppedSynonym,
                      synonymMatched: synonymMatched,
                      onDropped: _onSynonymDropped,
                      onNext: () {}, // Remove direct next since we handle it in _completeRound
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