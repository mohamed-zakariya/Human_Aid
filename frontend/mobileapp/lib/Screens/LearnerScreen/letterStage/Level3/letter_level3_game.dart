import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import '../../../../Services/add_score_service.dart';
import '../../../../generated/l10n.dart';
// import 'your_score_service_path.dart'; // Add your AddScoreService import

class LetterLevel3Game extends StatefulWidget {
  const LetterLevel3Game({super.key});

  @override
  State<LetterLevel3Game> createState() => _LetterLevel3GameState();
}

class _LetterLevel3GameState extends State<LetterLevel3Game> {
  final Map<String, List<String>> letterForms = {
    'ا': ['ا', 'ا', 'ـا', 'ـا'],
    'ب': ['ب', 'بـ', 'ـبـ', 'ـب'],
    'ت': ['ت', 'تـ', 'ـتـ', 'ـت'],
    'ث': ['ث', 'ثـ', 'ـثـ', 'ـث'],
    'ج': ['ج', 'جـ', 'ـجـ', 'ـج'],
    'ح': ['ح', 'حـ', 'ـحـ', 'ـح'],
    'خ': ['خ', 'خـ', 'ـخـ', 'ـخ'],
    'د': ['د', 'د', 'ـد', 'ـد'],
    'ذ': ['ذ', 'ذ', 'ـذ', 'ـذ'],
    'ر': ['ر', 'ر', 'ـر', 'ـر'],
    'ز': ['ز', 'ز', 'ـز', 'ـز'],
    'س': ['س', 'سـ', 'ـسـ', 'ـس'],
    'ش': ['ش', 'شـ', 'ـشـ', 'ـش'],
    'ص': ['ص', 'صـ', 'ـصـ', 'ـص'],
    'ض': ['ض', 'ضـ', 'ـضـ', 'ـض'],
    'ط': ['ط', 'طـ', 'ـطـ', 'ـط'],
    'ظ': ['ظ', 'ظـ', 'ـظـ', 'ـظ'],
    'ع': ['ع', 'عـ', 'ـعـ', 'ـع'],
    'غ': ['غ', 'غـ', 'ـغـ', 'ـغ'],
    'ف': ['ف', 'فـ', 'ـفـ', 'ـف'],
    'ق': ['ق', 'قـ', 'ـقـ', 'ـق'],
    'ك': ['ك', 'كـ', 'ـكـ', 'ـك'],
    'ل': ['ل', 'لـ', 'ـلـ', 'ـل'],
    'م': ['م', 'مـ', 'ـمـ', 'ـم'],
    'ن': ['ن', 'نـ', 'ـنـ', 'ـن'],
    'ه': ['ه', 'هـ', 'ـهـ', 'ـه'],
    'و': ['و', 'و', 'ـو', 'ـو'],
    'ي': ['ي', 'يـ', 'ـيـ', 'ـي'],
  };

  final List<String> arabicLetters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د',
    'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط',
    'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م',
    'ن', 'ه', 'و', 'ي'
  ];

  // Game state variables
  late String currentLetter;
  late List<String> draggableForms;
  Map<String, String?> droppedForms = {
    'منفصل': null,
    'متصل': null,
    'نهائي': null,
  };

  // Score and rounds variables
  int currentRound = 1;
  int totalRounds = 10;
  int score = 0;
  bool gameCompleted = false;

  // Timer variables
  Timer? timer;
  int timeLeft = 90; // Timer duration in seconds (configurable)
  int timerDuration = 90; // Store original timer duration

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      currentRound = 1;
      score = 0;
      gameCompleted = false;
      timeLeft = timerDuration;
    });
    _loadNewLetter();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        _endGame();
      }
    });
  }

  void _loadNewLetter() {
    final random = Random();
    final selected = arabicLetters[random.nextInt(arabicLetters.length)];
    final forms = letterForms[selected]!;

    setState(() {
      currentLetter = selected;
      draggableForms = [forms[0], forms[2], forms[3]]; // منفصل, متصل, نهائي
      draggableForms.shuffle(); // Randomize the draggable items
      droppedForms = {
        'منفصل': null,
        'متصل': null,
        'نهائي': null,
      };
    });
  }

  void _checkResult() {
    final forms = letterForms[currentLetter]!;
    bool isCorrect = droppedForms['منفصل'] == forms[0] &&
        droppedForms['متصل'] == forms[2] &&
        droppedForms['نهائي'] == forms[3];

    if (isCorrect) {
      setState(() {
        score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).correctFeedback,
            style: const TextStyle(fontSize: 24),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).wrongFeedback,
            style: const TextStyle(fontSize: 20),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Move to next round
    if (currentRound < totalRounds) {
      setState(() {
        currentRound++;
      });
      Future.delayed(const Duration(seconds: 2), _loadNewLetter);
    } else {
      timer?.cancel();
      Future.delayed(const Duration(seconds: 2), _endGame);
    }
  }

  void _endGame() async {
    setState(() {
      gameCompleted = true;
    });

    // Submit score
    try {
      // Uncomment when you have AddScoreService imported
      await AddScoreService.updateScore(
        score: score,
        outOf: totalRounds,
      );

      // Show completion dialog
      _showGameCompletionDialog();
    } catch (e) {
      // Handle error
      print('Error submitting score: $e');
      _showGameCompletionDialog();
    }
  }

  Future<void> _showGameCompletionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final local = S.of(context); // Short alias for localization
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% of screen width
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          title: Text(
            local.gameFinished,
            style: TextStyle(
              fontSize: screenWidth * 0.055, // Responsive font size
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.4, // Maximum 40% of screen height
              maxWidth: screenWidth * 0.8, // Maximum 80% of screen width
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: screenWidth * 0.15, // Responsive icon size (15% of screen width)
                    color: Colors.orangeAccent,
                  ),
                  SizedBox(height: screenHeight * 0.02), // Responsive spacing
                  Text(
                    local.wellDone,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // Responsive font size
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                SizedBox(
                  width: screenWidth * 0.25, // Responsive button width
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startGame(); // Restart game
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01,
                        horizontal: screenWidth * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      local.playAgain,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.25, // Responsive button width
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Exit to previous screen
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01,
                        horizontal: screenWidth * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      local.exit,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }



  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          '${args['gameName']}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: gameCompleted ? _buildGameCompletedScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight - 30, // Account for AppBar and safe area
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Game stats row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              S.of(context).roundLabel2,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentRound/$totalRounds',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              S.of(context).timeLabel,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(timeLeft),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: timeLeft <= 10 ? Colors.red : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Big Letter
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(
                    currentLetter,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.12, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ),

                // Draggables
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: draggableForms.map((form) => buildDraggable(form)).toList(),
                  ),
                ),

                // Drop Targets
                ...['منفصل', 'متصل', 'نهائي'].map((label) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: buildDropTarget(label),
                    ),
                ).toList(),

                const SizedBox(height: 16),

                // Verify Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _checkResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      S.of(context).verify,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCompletedScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: screenWidth * 0.25, // Responsive icon size
                color: Colors.orangeAccent,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                S.of(context).gameOverTitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.08, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.05),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: screenWidth * 0.05, // Responsive spacing
                runSpacing: screenHeight * 0.02,
                children: [
                  SizedBox(
                    width: screenWidth * 0.35, // Responsive button width
                    child: ElevatedButton(
                      onPressed: () {
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        S.of(context).playAgain,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.35, // Responsive button width
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        S.of(context).exit,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDraggable(String form) {
    return Draggable<String>(
      data: form,
      feedback: Material(
        color: Colors.transparent,
        child: buildDraggableLetter(form, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: buildDraggableLetter(form),
      ),
      child: buildDraggableLetter(form),
    );
  }

  Widget buildDraggableLetter(String form, {bool isDragging = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize = (screenWidth - 80) / 4; // Responsive size based on screen width
    containerSize = containerSize.clamp(60.0, 80.0); // Ensure minimum and maximum sizes

    return Container(
      width: containerSize,
      height: containerSize,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        form,
        style: TextStyle(
            fontSize: containerSize * 0.5, // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
    );
  }

  Widget buildDropTarget(String label) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          droppedForms[label] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.08, // Responsive height
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blueAccent : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '$label:',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                    fontWeight: FontWeight.w600
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  droppedForms[label] ?? '',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07, // Responsive font size
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}