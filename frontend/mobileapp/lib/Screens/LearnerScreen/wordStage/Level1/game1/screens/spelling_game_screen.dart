import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

// Import TTS service
import 'package:mobileapp/Services/tts_service.dart';

import '../widgets/help_sheet.dart';
import '../widgets/letter_slot.dart';
import '../widgets/letter_title.dart';
import '../widgets/synonym_section.dart';

// Models
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
}

// Main Game Screen
class SpellingGameScreen extends StatefulWidget {
  const SpellingGameScreen({super.key});

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

  final List<WordModel> wordList = [
    WordModel(
      word: "تفاحة",
      image: "assets/images/Apple.png",
      synonymChoices: ["فاكهة", "خضار", "مكتب", "سيارة"],
      correctSynonym: "فاكهة",
    ),
    WordModel(
      word: "كرسي",
      image: "assets/images/Chair.png",
      synonymChoices: ["مقعد", "باب", "كتاب", "تفاحة"],
      correctSynonym: "مقعد",
    ),
    WordModel(
      word: "منزل",
      image: "assets/images/House.jpg",
      synonymChoices: ["بيت", "طريق", "قلم", "سوق"],
      correctSynonym: "بيت",
    ),
  ];

  int currentIndex = 0;
  int score = 0;
  List<String?> selectedLetters = [];
  late List<String> shuffledLetters;
  bool isCorrect = false;
  bool showFullWord = false;
  bool showSynonymSection = false;
  String? droppedSynonym;
  bool synonymMatched = false;

  late final AnimationController _synonymSectionController;
  late final AnimationController _nextButtonController;
  late final AnimationController _successAnimationController;

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

    // Initialize sound effects
    _initSoundEffects();
    _loadQuestion();
  }

  Future<void> _initSoundEffects() async {
    await _correctPlayer.setSource(AssetSource('sounds/correct.mp3'));
    await _incorrectPlayer.setSource(AssetSource('sounds/incorrect.mp3'));
    await _clickPlayer.setSource(AssetSource('sounds/click.mp3'));
    await _dropPlayer.setSource(AssetSource('sounds/drop.mp3'));
    await _successPlayer.setSource(AssetSource('sounds/success.mp3'));

    // Initialize TTS service
    await ttsService.initialize(language: "ar:EG");
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  void _loadQuestion() {
    final wordModel = wordList[currentIndex];
    final word = wordModel.word;

    shuffledLetters = word.split('')..shuffle(Random());
    selectedLetters = List.filled(word.length, null);
    isCorrect = false;
    showFullWord = false;
    showSynonymSection = false;
    droppedSynonym = null;
    synonymMatched = false;

    _successAnimationController.reset();
    _synonymSectionController.reset();
    _nextButtonController.reset();
  }

  void _checkAnswer() {
    final userAnswer = selectedLetters.join();
    final correctWord = wordList[currentIndex].word;

    if (userAnswer == correctWord) {
      // Play success sound
      _correctPlayer.resume();

      // Also speak the word using TTS
      ttsService.speak(correctWord);

      setState(() {
        isCorrect = true;
        score++;
        showFullWord = true;
        showSynonymSection = true;
      });

      _successAnimationController.forward();
      _synonymSectionController.forward();
    } else {
      // Play incorrect sound
      _incorrectPlayer.resume();

      // Reset slots if answer is incorrect
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          selectedLetters = List.filled(correctWord.length, null);
        });
      });
    }
  }

  void _onSynonymDropped(String choice) {
    final correct = wordList[currentIndex].correctSynonym;

    // Play drop sound
    _dropPlayer.resume();

    setState(() {
      droppedSynonym = choice;
      synonymMatched = choice == correct;

      if (synonymMatched) {
        // Play success sound for correct synonym
        _successPlayer.resume();
        _nextButtonController.forward();
      } else {
        // Play error sound for incorrect synonym
        _incorrectPlayer.resume();
      }
    });
  }

  void _onNext() {
    // Play click sound
    _clickPlayer.resume();

    if (currentIndex < wordList.length - 1) {
      setState(() {
        currentIndex++;
        _loadQuestion();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    // Play success sound for game completion
    _successPlayer.resume();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎊 انتهت اللعبة!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "نتيجتك: $score / ${wordList.length} 🏆",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Play click sound
                _clickPlayer.resume();
                Navigator.pop(context);
                setState(() {
                  score = 0;
                  currentIndex = 0;
                  _loadQuestion();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F73FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("🔁 العب مرة أخرى", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = wordList[currentIndex].word;
    final image = wordList[currentIndex].image;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('لعبة التهجئة', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF7F73FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Play click sound
              final player = AudioPlayer();
              player.setSource(AssetSource('sounds/click.mp3'));
              player.resume();

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => HelpSheet(),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Purple header area
          Container(
            height: 60,
            width: double.infinity,
            color: const Color(0xFF7F73FF),
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
                      const TextSpan(text: "السؤال "),
                      TextSpan(
                        text: "${currentIndex + 1}",
                        style: const TextStyle(color: Colors.yellow, fontSize: 20), // Change color as desired
                      ),
                      TextSpan(text: " / ${wordList.length}"),
                    ],
                  ),
                ),
              ),
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
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Letter slots
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(word.length, (index) {
                      return LetterSlot(
                        letter: selectedLetters[index],
                        onAccept: (data) {
                          setState(() {
                            selectedLetters[index] = data;
                            if (!selectedLetters.contains(null)) _checkAnswer();
                          });
                        },
                      );
                    }).reversed.toList(),
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
                          margin: const EdgeInsets.fromLTRB(0,0,0,5),
                          child: IconButton(
                            onPressed: () => {
                              ttsService.setLanguage('ar-EG'),
                              ttsService.speak(word)
                            },
                            icon: const Icon(Icons.volume_up, color: Color(0xFF7F73FF)),
                            tooltip: "استمع إلى الكلمة",
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // Synonym section
                  if (showSynonymSection)
                    SynonymSection(
                      choices: wordList[currentIndex].synonymChoices,
                      droppedSynonym: droppedSynonym,
                      synonymMatched: synonymMatched,
                      onDropped: _onSynonymDropped,
                      onNext: _onNext,
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


