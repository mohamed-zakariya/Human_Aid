import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Services/add_score_service.dart';
import '../../../../Services/sentence_exercise_service.dart';
import '../../../../models/scentence.dart';

class SentenceOrderingGameScreen extends StatefulWidget {
  final String level;

  const SentenceOrderingGameScreen(this.level, {Key? key}) : super(key: key);

  @override
  State<SentenceOrderingGameScreen> createState() =>
      _SentenceOrderingGameScreenState();
}

class _SentenceOrderingGameScreenState extends State<SentenceOrderingGameScreen>
    with TickerProviderStateMixin {
  // Game Configuration
  static const int maxRounds = 10;
  static const int maxListenAttempts = 2;

  // Game State
  int currentRound = 0;
  int totalScore = 0;
  int currentListenAttempts = 0;
  bool isGameStarted = false;
  bool areCardsFlipped = false;
  bool isListening = false;
  bool isGameCompleted = false;
  bool isRoundCompleted = false;

  // Data
  List<Sentence> currentSentences = [];
  List<Sentence> correctOrder = [];
  List<Sentence> userOrder = [];
  List<Sentence> shuffledSentences = [];

  // Services
  FlutterTts flutterTts = FlutterTts();

  // SharedPreferences Keys
  String? exerciseId;
  String? levelId;
  String? learnerId;
  String? gameId;
  String? levelGameId;
  String? roundKey;
  String? scoreKey;

  // Animation Controllers
  late AnimationController _cardFlipController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _loadGameState();
  }

  void _initializeAnimations() {
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardFlipController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    // Get stored IDs
    exerciseId = prefs.getString('exerciseId');
    levelId = prefs.getString('levelId');
    learnerId = prefs.getString('learnerId');
    gameId = prefs.getString('gameId');
    levelGameId = prefs.getString('levelGameId');

    if (levelId != null && gameId != null) {
      roundKey = '${levelId}_${gameId}_${levelGameId}_round';
      scoreKey = '${levelId}_${gameId}_${levelGameId}_score';

      currentRound = prefs.getInt(roundKey!) ?? 0;
      totalScore = prefs.getInt(scoreKey!) ?? 0;

      if (currentRound < 0) currentRound = 0;
      if (currentRound >= maxRounds) currentRound = maxRounds - 1;
      if (totalScore < 0) totalScore = 0;
      if (totalScore > maxRounds * 2) totalScore = maxRounds * 2;

      _progressController.animateTo(currentRound / maxRounds);
    }

    await _loadNewRound();
  }

  Future<void> _saveGameState() async {
    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(roundKey!, currentRound);
      await prefs.setInt(scoreKey!, totalScore);
    }
  }

  Future<void> _loadNewRound() async {
    try {
      setState(() {
        isListening = true;
        areCardsFlipped = false;
        isRoundCompleted = false;
        currentListenAttempts = 0;
        userOrder.clear();
      });

      _cardFlipController.reset();

      final sentences =
      await SentenceExerciseService.fetchRandomSentences(widget.level);

      if (sentences.isNotEmpty) {
        currentSentences = sentences.take(4).toList();
        correctOrder = List.from(currentSentences);
        shuffledSentences = List.from(currentSentences);
        shuffledSentences.shuffle(Random());

        setState(() {
          isGameStarted = true;
          isListening = false;
        });

        // Auto-play first time
        await _speakSentencesInOrder();
      }
    } catch (e) {
      print("Error loading new round: $e");
      _showErrorDialog("خطأ في تحميل الجملة الجديدة");
    }
  }

  Future<void> _speakSentencesInOrder() async {
    if (currentListenAttempts >= maxListenAttempts) return;

    setState(() {
      isListening = true;
      currentListenAttempts++;
    });

    try {
      for (int i = 0; i < correctOrder.length; i++) {
        await flutterTts.speak(correctOrder[i].text);
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    } catch (e) {
      print("TTS Error: $e");
    }

    setState(() {
      isListening = false;
    });

    // Auto-flip cards after listening
    if (!areCardsFlipped) {
      await Future.delayed(const Duration(milliseconds: 500));
      _flipCards();
    }
  }

  void _flipCards() {
    setState(() {
      areCardsFlipped = true;
    });
    _cardFlipController.forward();
  }

  void _onDragAccept(Sentence sentence) {
    if (!userOrder.contains(sentence)) {
      setState(() {
        userOrder.add(sentence);
      });
    }
  }

  void _removeFromUserOrder(int index) {
    setState(() {
      userOrder.removeAt(index);
    });
  }

  void _onReorderUserOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = userOrder.removeAt(oldIndex);
      userOrder.insert(newIndex, item);
    });
  }

  void _checkAnswer() {
    if (userOrder.length != correctOrder.length) {
      _showMessage("يرجى ترتيب جميع الجمل");
      return;
    }

    bool isCorrect = true;
    for (int i = 0; i < correctOrder.length; i++) {
      if (userOrder[i].id != correctOrder[i].id) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      isRoundCompleted = true;
      if (isCorrect) {
        totalScore += 2;
      }
    });

    _saveGameState();
    _showResultDialog(isCorrect);
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              isCorrect
                  ? ("إجابة صحيحة!")
                  : ("إجابة خاطئة"),
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${"النقاط"}: ${isCorrect ? '+2' : '+0'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "${"المجموع"}: $totalScore ${"من"} ${maxRounds * 2}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextRound();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              currentRound + 1 >= maxRounds
                  ? ("إنهاء اللعبة")
                  : ("الجولة التالية"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _nextRound() {
    if (currentRound + 1 >= maxRounds) {
      _completeGame();
    } else {
      setState(() {
        currentRound++;
      });
      _progressController.animateTo(currentRound / maxRounds);
      _saveGameState();
      _loadNewRound();
    }
  }

  Future<void> _completeGame() async {
    setState(() {
      isGameCompleted = true;
    });

    try {
      await AddScoreService.updateScore(
        score: totalScore,
        outOf: maxRounds * 2,
      );
    } catch (e) {
      print("Error submitting score: $e");
    }

    if (roundKey != null && scoreKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(roundKey!);
      await prefs.remove(scoreKey!);
    }

    _showGameCompletedDialog();
  }

  void _showGameCompletedDialog() {
    final percentage = (totalScore / (maxRounds * 2) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 30),
            const SizedBox(width: 10),
            Text(
              "اللعبة مكتملة!",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${"النقاط النهائية"}: $totalScore ${"من"} ${maxRounds * 2}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${"النسبة المئوية"}: %$percentage",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Text(
              percentage >= 80
                  ? ("أداء ممتاز!")
                  : percentage >= 60
                  ? ("أداء جيد!")
                  : ("تحتاج إلى مزيد من التدريب"),
              style: TextStyle(
                fontSize: 14,
                color: percentage >= 80
                    ? Colors.green
                    : percentage >= 60
                    ? Colors.orange
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "العودة للقائمة",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "لعب مرة أخرى",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      currentRound = 0;
      totalScore = 0;
      isGameCompleted = false;
      isGameStarted = false;
    });
    _progressController.reset();
    _loadNewRound();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardFlipController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactHeader(),
            Expanded(
              child: isGameStarted ? _buildGameContent() : _buildLoadingScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  "${"ترتيب الجمل"} - ${widget.level}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "$totalScore/${maxRounds * 2}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "${"الجولة"} ${currentRound + 1}/$maxRounds",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          const SizedBox(height: 20),
          Text(
            "جاري تحميل اللعبة...",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        if (areCardsFlipped) _buildListenSection(),
        Expanded(child: _buildGameArea()),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildListenSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isListening ? _pulseAnimation.value : 1.0,
            child: ElevatedButton.icon(
              onPressed: (currentListenAttempts < maxListenAttempts && !isListening)
                  ? _speakSentencesInOrder
                  : null,
              icon: isListening
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.volume_up, size: 20),
              label: Text(
                isListening
                    ? ("جاري التشغيل...")
                    : "${"استمع"} (${maxListenAttempts - currentListenAttempts})",
                style: const TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildSentenceCards(),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: _buildOrderingArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCards() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: shuffledSentences.length,
      itemBuilder: (context, index) {
        return _buildSentenceCard(shuffledSentences[index], index);
      },
    );
  }

  Widget _buildSentenceCard(Sentence sentence, int index) {
    return AnimatedBuilder(
      animation: _cardFlipAnimation,
      builder: (context, child) {
        final isShowingFront = _cardFlipAnimation.value < 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardFlipAnimation.value * 3.14159),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isShowingFront
                ? _buildCardFront(index)
                : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(3.14159),
              child: _buildDraggableCard(sentence),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.headphones, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              "${index + 1}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableCard(Sentence sentence) {
    final isUsed = userOrder.contains(sentence);

    return Draggable<Sentence>(
      data: sentence,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF6C63FF).withOpacity(0.9),
          ),
          child: Center(
            child: Text(
              sentence.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.drag_indicator, color: Colors.grey, size: 24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isUsed ? Colors.grey[200] : Colors.white,
          border: Border.all(
            color: isUsed ? Colors.grey[300]! : const Color(0xFF6C63FF),
            width: 2,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              sentence.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUsed ? Colors.grey : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderingArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sort, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  "رتب الجمل بالترتيب الصحيح",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: userOrder.isEmpty
                ? DragTarget<Sentence>(
              onAccept: _onDragAccept,
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isHighlighted
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isHighlighted
                        ? const Color(0xFF6C63FF).withOpacity(0.1)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "اسحب الجمل هنا لترتيبها",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ]),
                ),
                );
              },
            )
                : ReorderableListView.builder(
              padding: const EdgeInsets.all(10),
              onReorder: _onCardReorder,
              itemCount: userOrder.length,
              itemBuilder: (context, index) {
                return _buildOrderedCard(userOrder[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }


  void _onCardReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = userOrder.removeAt(oldIndex);
      userOrder.insert(newIndex, item);
    });
  }

  Widget _buildOrderedCard(Sentence sentence, int index) {
    return Card(
      key: ValueKey(sentence.id),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            "${index + 1}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          sentence.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeFromUserOrder(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: userOrder.length == currentSentences.length && !isRoundCompleted
                  ? _checkAnswer
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: const Text(
                "تأكيد الإجابة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}