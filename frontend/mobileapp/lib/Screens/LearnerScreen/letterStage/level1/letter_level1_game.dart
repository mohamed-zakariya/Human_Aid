import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/letter.dart';
import '../../../../Services/tts_service.dart';
import '../../../../Services/letters_service.dart';

class LetterLevel1Game extends StatefulWidget {
  const LetterLevel1Game({super.key});

  @override
  State<LetterLevel1Game> createState() => _LetterLevel1GameState();
}

class _LetterLevel1GameState extends State<LetterLevel1Game> {
  final List<Color> colors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.brown, Colors.pink,
    Colors.indigo, Colors.amber, Colors.deepOrange, Colors.cyan,
    Colors.deepPurple, Colors.lime, Colors.lightBlue, Colors.lightGreen,
    Colors.yellow, Colors.blueGrey, Colors.redAccent, Colors.greenAccent,
    Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent,
    Colors.pinkAccent, Colors.indigoAccent, Colors.amberAccent, Colors.cyanAccent,
  ];

  final TTSService _ttsService = TTSService();
  List<Letter> allLetters = [];
  bool isLoading = true;

  static const int totalRounds = 10;
  int currentRound = 0;
  int score = 0;

  List<Letter> currentOptions = [];
  List<Color> optionColors = [];
  late Letter targetLetter;
  String? selectedLetter;
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize(language: 'ar-SA');
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    setState(() => isLoading = true);
    final fetchedLetters = await LettersService.getLettersForLevel1();
    if (fetchedLetters != null) {
      allLetters = fetchedLetters;
      _startNewRound();
    }
    setState(() => isLoading = false);
  }

  void _startNewRound() {
    if (currentRound >= totalRounds) {
      _showGameOverDialog();
      return;
    }

    final random = Random();
    final shuffledLetters = [...allLetters]..shuffle();
    currentOptions = shuffledLetters.take(6).toList();
    targetLetter = currentOptions[random.nextInt(6)];
    selectedLetter = null;
    showFeedback = false;

    final shuffledColors = [...colors]..shuffle(random);
    optionColors = shuffledColors.take(6).toList();

    _ttsService.speak(targetLetter.letter);
    setState(() => currentRound++);
  }

  void _checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      showFeedback = true;
      if (letter == targetLetter.letter) {
        score++;
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('انتهت اللعبة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score >= 8
                  ? '🎉 أحسنت! عمل رائع!\nدرجتك: $score من $totalRounds'
                  : '😊 لا بأس! حاول مرة أخرى\nدرجتك: $score من $totalRounds',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('إعادة'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      currentRound = 0;
      score = 0;
    });
    _startNewRound();
  }

  @override
  void dispose() {
    _ttsService.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لعبة الحروف'),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'الجولة $currentRound من $totalRounds',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _ttsService.speak(targetLetter.letter),
              icon: const Icon(Icons.volume_up, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                child: Text(
                  'استمع إلى الحرف',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
            ),
            if (showFeedback)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  selectedLetter == targetLetter.letter
                      ? '🎉 صحيح!'
                      : '❌ خطأ، الصحيح: ${targetLetter.letter}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: selectedLetter == targetLetter.letter ? Colors.green : Colors.red,
                  ),
                ),
              ),
            if (showFeedback)
              ElevatedButton(
                onPressed: _startNewRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60), // Bigger width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('التالي'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
