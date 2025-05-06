import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobileapp/models/letter.dart';
import '../../../../Services/letters_service.dart';
import '../letter_forms.dart';

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
    currentOptions = shuffledLetters.take(10).toList();
    targetLetter = currentOptions[random.nextInt(10)];
    selectedLetter = null;
    showFeedback = false;

    final shuffledColors = [...colors]..shuffle(random);
    optionColors = shuffledColors.take(10).toList();

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
      barrierColor: Colors.black.withOpacity(0.6), // Dim the background
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E), // Darker dialog background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            '🎮 انتهت اللعبة',
            style: TextStyle(
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
                  ? '🎉 أحسنت! عمل رائع!\nدرجتك: $score من $totalRounds'
                  : '😊 لا بأس! حاول مرة أخرى\nدرجتك: $score من $totalRounds',
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
            child: const Text(
              'إعادة اللعب',
              style: TextStyle(fontSize: 16),
            ),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Darker dialog background
        title: const Text(
          'طريقة اللعب 🎯',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '1️⃣ اضغط على زر "استمع إلى الحرف" لسماع الحرف المطلوب.\n\n'
                  '2️⃣ اختر الحرف الصحيح من بين الخيارات الملونة.\n\n'
                  '3️⃣ تحصل على نقطة لكل إجابة صحيحة. اجمع أكثر من 8 للفوز!',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),
            // Button to listen to instructions
            ElevatedButton.icon(
              onPressed: () {
                _flutterTts.speak('1 اضغط على زر "استمع إلى الحرف" لسماع الحرف المطلوب. 2 اختر الحرف الصحيح من بين الخيارات الملونة. 3 تحصل على نقطة لكل إجابة صحيحة. اجمع أكثر من 8 للفوز!');
              },
              icon: const Icon(Icons.volume_up, size: 28), // Add your icon here
              label: const Text('استمع للتعليمات', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            )

          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _flutterTts.stop();
              Navigator.pop(context);
            },
            child: const Text('حسنًا', style: TextStyle(fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2C2C2E), // Darker dialog background
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Text('لعبة الحروف'),
          ],
        ),
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
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'الجولة $currentRound من $totalRounds',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _flutterTts.speak(targetLetter.letter),
                icon: const Icon(Icons.volume_up, size: 28),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'استمع إلى الحرف',
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
              ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    selectedLetter == targetLetter.letter
                        ? '🎉 صحيح!'
                        : '❌ خطأ، الصحيح: ${targetLetter.letter}',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: selectedLetter == targetLetter.letter
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              if (showFeedback)
                ElevatedButton(
                  onPressed: _startNewRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
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
                  child: const Text('التالي'),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}