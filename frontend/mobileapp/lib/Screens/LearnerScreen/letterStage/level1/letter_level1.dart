import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileapp/models/letter.dart';
import 'package:mobileapp/models/learner.dart';

import '../../../../Services/letters_exercise_service.dart';
import '../../../../Services/tts_service.dart';
import '../../../../Services/letters_service.dart';

class LetterLevel1 extends StatefulWidget {
  final String exerciseId;
  final String levelId;
  final Learner learner;

  const LetterLevel1({
    Key? key,
    required this.exerciseId,
    required this.levelId,
    required this.learner,
  }) : super(key: key);

  @override
  State<LetterLevel1> createState() => _LetterLevel1State();
}

class _LetterLevel1State extends State<LetterLevel1>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TTSService _ttsService = TTSService();

  List<Letter> letters = [];
  bool isLoading = true;
  bool isSubmitting = false;

  Map<String, Color> groupColorMap = {};

  // Progress tracking
  int currentLetterIndex = 0;
  int listenCount = 0;
  bool canProceedToNext = false;
  bool isLevelCompleted = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Colors for different groups
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.brown,
    Colors.grey,
    Colors.deepPurple,
    Colors.lightBlue,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLevel();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeLevel() async {
    await _loadProgress();
    await _fetchLetters();
    await _ttsService.initialize(language: 'ar-SA');
    _checkLevelCompletion();
    if (!isLevelCompleted) {
      _slideController.forward();
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'letters_${widget.levelId}';
    final savedProgress = prefs.getInt(progressKey) ?? 0;

    setState(() {
      currentLetterIndex = savedProgress;
      if (currentLetterIndex >= 28) {
        isLevelCompleted = true;
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'letters_${widget.levelId}';
    await prefs.setInt(progressKey, currentLetterIndex);
  }

  Future<void> _fetchLetters() async {
    setState(() {
      isLoading = true;
    });

    final fetchedLetters = await LettersService.fetchLetters();

    if (fetchedLetters != null && fetchedLetters.isNotEmpty) {
      _createGroupColorMapping(fetchedLetters);

      setState(() {
        letters = fetchedLetters;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("خطأ في تحميل الحروف");
    }
  }

  void _createGroupColorMapping(List<Letter> letters) {
    groupColorMap.clear();
    final uniqueGroups = letters.map((l) => l.group).toSet().toList();

    for (int i = 0; i < uniqueGroups.length; i++) {
      groupColorMap[uniqueGroups[i]] = colors[i % colors.length];
    }
  }

  void _checkLevelCompletion() {
    if (currentLetterIndex >= 28) {
      setState(() {
        isLevelCompleted = true;
      });
      _showCompletionDialog();
    }
  }

  Future<void> playLetterSound(String letter) async {
    try {
      await _ttsService.speak(letter);
      setState(() {
        listenCount++;
        if (listenCount >= 3) {
          canProceedToNext = true;
        }
      });
    } catch (e) {
      print('Error speaking letter: $e');
      _showErrorDialog('خطأ في تشغيل الصوت');
    }
  }

  Future<void> _proceedToNextLetter() async {
    if (!canProceedToNext) {
      _showInfoDialog('يجب الاستماع للحرف 3 مرات قبل المتابعة');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await LetterExerciseService.submitLetter(
        userId: widget.learner.id,
        exerciseId: widget.exerciseId,
        levelId: widget.levelId,
        letter: letters[currentLetterIndex],
        spokenLetter: letters[currentLetterIndex].letter,
      );

      if (result['isCorrect'] == true) {
        setState(() {
          currentLetterIndex++;
          listenCount = 0;
          canProceedToNext = false;
        });

        await _saveProgress();

        if (currentLetterIndex >= letters.length) {
          setState(() {
            isLevelCompleted = true;
          });
          _showCompletionDialog();
        } else {
          // Animate to next letter
          _slideController.reset();
          _slideController.forward();
          _showSuccessDialog('أحسنت! انتقل للحرف التالي');
        }
      } else {
        _showErrorDialog(result['message'] ?? 'حدث خطأ، حاول مرة أخرى');
      }
    } catch (e) {
      print('Error submitting letter: $e');
      _showErrorDialog('حدث خطأ غير متوقع');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _resetLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'letters_${widget.levelId}';
    await prefs.remove(progressKey);

    setState(() {
      currentLetterIndex = 0;
      listenCount = 0;
      canProceedToNext = false;
      isLevelCompleted = false;
    });

    _slideController.reset();
    _slideController.forward();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('تهانينا!'),
          ],
        ),
        content: const Text(
          'لقد أكملت هذا المستوى بنجاح!\nهل تريد المراجعة أم الانتقال للمستوى التالي؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetLevel();
            },
            child: const Text('مراجعة'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('المستوى التالي'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('خطأ'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Text('تنبيه'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('ممتاز!'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLetterCard() {
    if (letters.isEmpty || currentLetterIndex >= letters.length) {
      return const SizedBox.shrink();
    }

    final letter = letters[currentLetterIndex];
    final groupColor = groupColorMap[letter.group] ?? Colors.grey;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              groupColor.withOpacity(0.8),
              groupColor,
              groupColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: groupColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Listen progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.headphones, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'استمع ${listenCount}/3 مرات',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Main letter display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: canProceedToNext ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter.letter,
                          style: TextStyle(
                            fontSize: 160,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(3.0, 3.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Listen button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: groupColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () => playLetterSound(letter.letter),
                        icon: const Icon(Icons.volume_up, size: 28),
                        label: const Text(
                          'استمع',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  // Next button
                  if (canProceedToNext) ...[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: isSubmitting ? null : _proceedToNextLetter,
                          icon: isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Icon(Icons.arrow_forward, size: 28),
                          label: Text(
                            isSubmitting ? '' : 'التالي',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLevelCompleted) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'تهانينا! 🎉',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'لقد أكملت جميع الحروف في هذا المستوى',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetLevel,
                      icon: const Icon(Icons.refresh),
                      label: const Text('مراجعة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('المستوى التالي'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: Text("المستوي الأول (${currentLetterIndex + 1}/28)"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetLevel,
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تشغيل المستوى',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Enhanced progress bar
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقدم: ${currentLetterIndex}/28',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      Text(
                        '${((currentLetterIndex / 28) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: currentLetterIndex / 28,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // Main letter card
            Expanded(
              child: _buildCurrentLetterCard(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _ttsService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}