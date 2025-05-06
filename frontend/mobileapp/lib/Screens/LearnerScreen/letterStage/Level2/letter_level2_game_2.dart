import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobileapp/models/letter.dart';
import '../../../../Services/tts_service.dart';
import '../../../../Services/letters_service.dart';
import '../../../../generated/l10n.dart';

class LetterLevel2Game2 extends StatefulWidget {
  const LetterLevel2Game2({super.key});

  @override
  State<LetterLevel2Game2> createState() => _LetterLevel2Game2State();
}

class _LetterLevel2Game2State extends State<LetterLevel2Game2> {
  final TTSService _ttsService = TTSService();

  List<Letter> allLetters = [];
  bool isLoading = true;

  static const int totalRounds = 10;
  int currentRound = 0;
  int score = 0;

  List<Letter> currentOptions = [];
  late Letter targetLetter;
  String? selectedLetter;
  bool showFeedback = false;

  List<double> rotationAngles = [];

  int remainingAttempts = 2; // NEW

  @override
  void initState() {
    super.initState();
    _ttsService.initialize(language: 'ar-EG');
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
    currentOptions = shuffledLetters.take(12).toList();
    targetLetter = currentOptions[random.nextInt(12)];
    selectedLetter = null;
    showFeedback = false;

    remainingAttempts = 2; // ✅ Reset attempts

    rotationAngles = List.generate(12, (_) {
      final angleOptions = [0.0, -0.2, 0.2, -0.4, 0.4, -0.6, 0.6];
      return angleOptions[random.nextInt(angleOptions.length)];
    });

    setState(() {
      currentRound++;
    });

    // ❌ REMOVE automatic audio playback here
    // _ttsService.speak(targetLetter.letter);
    // remainingAttempts--;
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

  void _restartGame() {
    setState(() {
      currentRound = 0;
      score = 0;
    });
    _startNewRound();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.teal.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('🎮 انتهت اللعبة',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= 8 ? Icons.emoji_events : Icons.sentiment_satisfied,
              size: 64,
              color: score >= 8 ? Colors.amber : Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              score >= 8
                  ? S.of(context).greatJob(score.toString(), totalRounds.toString())
                  : S.of(context).tryAgain2(score.toString(), totalRounds.toString()),
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إعادة اللعب', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    void showInfoDialog() {
      final currentLocale = Localizations.localeOf(context).languageCode;
      final isArabic = currentLocale == 'ar';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(S.of(context).howToPlayTitle),
          content: Text(S.of(context).howToPlayDescription),
          actions: [
            TextButton(
              onPressed: () {
                _ttsService.stop(); // Stop TTS before closing dialog
                Navigator.pop(context);
              },
              child: Text(S.of(context).okButton),
            ),

            TextButton(
              onPressed: () {
                Localizations.localeOf(context).languageCode == 'ar'?
                _ttsService.setLanguage('ar-EG'):
                _ttsService.setLanguage('en-US');
                _ttsService.speak(S.of(context).howToPlayDescription);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.volume_up),
                  SizedBox(width: 8),
                  Text("Read Aloud"),
                ],
              ),
            ),
          ],
        ),
      );
    }



    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).exercise2Title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: showInfoDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 16),
          Text(
            S.of(context).roundLabel(currentRound.toString(), totalRounds.toString()),
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 16),
          if (remainingAttempts >= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: remainingAttempts > 0
                    ? () {
                  _ttsService.setLanguage('ar-EG');
                  _ttsService.speak(targetLetter.letter);
                  setState(() {
                    remainingAttempts--;
                  });
                }
                    : null, // Disables the button when attempts are 0
                icon: const Icon(Icons.volume_up),
                label: Text('${S.of(context).listen} ($remainingAttempts)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ).copyWith(
                  // Dim the button when disabled
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.orange.withOpacity(0.4); // Dim the button
                    }
                    return Colors.orange;
                  }),
                ),
              ),
            ),
          Expanded(
            child: GridView.builder(
              itemCount: currentOptions.length,
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final letter = currentOptions[index].letter;
                return FishWidget(
                  letter: letter,
                  rotationAngle: rotationAngles[index],
                  onTap: selectedLetter == null ? () => _checkAnswer(letter) : null,
                  isSelected: selectedLetter == letter,
                  isCorrect: letter == targetLetter.letter,
                );
              },
            ),
          ),
          if (showFeedback)
            Text(
              selectedLetter == targetLetter.letter
                  ? S.of(context).correctAnswer
                  : S.of(context).wrongAnswer(targetLetter.letter),
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: selectedLetter == targetLetter.letter ? Colors.green : Colors.red,
              ),
            ),
          const SizedBox(height: 8),
          if (selectedLetter != null)
            ElevatedButton(
              onPressed: _startNewRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(S.of(context).nextButton, style: TextStyle(fontSize: 18)),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class FishWidget extends StatelessWidget {
  final String letter;
  final double size;
  final double rotationAngle;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;

  const FishWidget({
    super.key,
    required this.letter,
    required this.rotationAngle,
    this.size = 80,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
          ),
          child: CustomPaint(
            painter: FishPainter(),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FishPainter extends CustomPainter {
  final Color color;

  FishPainter({this.color = Colors.orange});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final body = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, size.height, size.width * 0.2, size.height * 0.5)
      ..close();

    final tail = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(0, size.height * 0.75)
      ..close();

    canvas.drawPath(body, paint);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
