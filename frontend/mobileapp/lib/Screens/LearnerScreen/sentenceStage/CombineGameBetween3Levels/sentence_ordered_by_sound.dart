import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Services/add_score_service.dart';
import '../../../../Services/sentence_exercise_service.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/scentence.dart';

class SentenceOrderingGameScreen extends StatefulWidget {
  final String level;
  const SentenceOrderingGameScreen(this.level, {Key? key}) : super(key: key);

  @override
  State<SentenceOrderingGameScreen> createState() => _SentenceOrderingGameScreenState();
}

class _SentenceOrderingGameScreenState extends State<SentenceOrderingGameScreen> {
  static const int maxRounds = 10;
  static const int maxListenAttempts = 2;
  static const int pointsPerRound = 1; // Changed from 2 to 1

  int currentRound = 0;
  int totalScore = 0;
  int currentListenAttempts = 0;
  bool isGameStarted = false;
  bool areCardsFlipped = false;
  bool isListening = false;
  bool canUseListenAttempts = true;

  List<Sentence> correctOrder = [];
  List<Sentence> userOrder = [];
  List<Sentence> shuffledSentences = [];

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadGameState();
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final levelId = prefs.getString('levelId');
    final gameId = prefs.getString('gameId');

    if (levelId != null && gameId != null) {
      final roundKey = '${levelId}_${gameId}_round';
      final scoreKey = '${levelId}_${gameId}_score';

      currentRound = prefs.getInt(roundKey) ?? 0;
      totalScore = prefs.getInt(scoreKey) ?? 0;

      // Validate bounds - updated for 1 point per round
      currentRound = currentRound.clamp(0, maxRounds - 1);
      totalScore = totalScore.clamp(0, maxRounds);
    }

    await _loadNewRound();
  }

  Future<void> _loadNewRound() async {
    try {
      setState(() {
        isListening = true;
        areCardsFlipped = false;
        currentListenAttempts = 0;
        canUseListenAttempts = true;
        userOrder.clear();
      });

      final sentences = await SentenceExerciseService.fetchRandomSentences(widget.level);

      if (sentences.isNotEmpty) {
        correctOrder = sentences.take(4).toList();
        shuffledSentences = List.from(correctOrder)..shuffle(Random());

        setState(() {
          isGameStarted = true;
          isListening = false;
        });
      }
    } catch (e) {
      _showErrorDialog("خطأ في تحميل الجملة الجديدة");
    }
  }

  Future<void> _speakSentencesInOrder() async {
    if (!canUseListenAttempts || currentListenAttempts >= maxListenAttempts) return;

    setState(() {
      isListening = true;
      currentListenAttempts++;
    });

    try {
      await flutterTts.awaitSpeakCompletion(true); // Ensure we wait for each sentence
      for (var sentence in correctOrder) {
        await flutterTts.speak(sentence.text);
        await Future.delayed(const Duration(milliseconds: 800)); // Add clear pause between sentences
      }
    } catch (e) {
      print("TTS Error: $e");
    }

    setState(() => isListening = false);
  }


  void _flipCards() {
    setState(() {
      areCardsFlipped = true;
      canUseListenAttempts = false; // Disable listen attempts after flipping
    });
  }

  void _onDragAccept(Sentence sentence) {
    if (!userOrder.contains(sentence)) {
      setState(() => userOrder.add(sentence));
    }
  }

  void _removeFromUserOrder(int index) {
    setState(() => userOrder.removeAt(index));
  }

  void _onReorderUserOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
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

    if (isCorrect) totalScore += pointsPerRound; // Now adds 1 point instead of 2
    _saveGameState();
    _showResultDialog(isCorrect);
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final levelId = prefs.getString('levelId');
    final gameId = prefs.getString('gameId');

    if (levelId != null && gameId != null) {
      await prefs.setInt('${levelId}_${gameId}_round', currentRound);
      await prefs.setInt('${levelId}_${gameId}_score', totalScore);
    }
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(isCorrect ? S.of(context).correctAnswer2 : S.of(context).wrongAnswer2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${S.of(context).points}: ${isCorrect ? '+$pointsPerRound' : '+0'}"),
            Text(S.of(context).finalScore(totalScore, maxRounds)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextRound();
            },
            child: Text(currentRound + 1 >= maxRounds
                ? S.of(context).endGame
                : S.of(context).nextRound),
          ),
        ],
      ),
    );
  }

  void _nextRound() {
    if (currentRound + 1 >= maxRounds) {
      _completeGame();
    } else {
      setState(() => currentRound++);
      _saveGameState();
      _loadNewRound();
    }
  }

  Future<void> _completeGame() async {
    try {
      await AddScoreService.updateScore(score: totalScore, outOf: maxRounds);
    } catch (e) {
      print("Error submitting score: $e");
    }
    _showGameCompletedDialog();
  }

  void _showGameCompletedDialog() {
    final percentage = (totalScore / maxRounds * 100).round();
    String performanceMessage = "";
    Color performanceColor = Colors.blue;
    IconData performanceIcon = Icons.emoji_events;

    // Add performance feedback based on score
    if (percentage >= 90) {
      performanceMessage = S.of(context).performanceExcellent;
      performanceColor = Colors.green;
      performanceIcon = Icons.star;
    } else if (percentage >= 70) {
      performanceMessage = S.of(context).performanceVeryGood;
      performanceColor = Colors.blue;
      performanceIcon = Icons.thumb_up;
    } else if (percentage >= 50) {
      performanceMessage = S.of(context).performanceGood;
      performanceColor = Colors.orange;
      performanceIcon = Icons.trending_up;
    } else {
      performanceMessage = S.of(context).performanceTryAgain;
      performanceColor = Colors.red;
      performanceIcon = Icons.refresh;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(performanceIcon, color: performanceColor, size: 28),
            const SizedBox(width: 10),
            Text(S.of(context).gameCompleted)
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: performanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: performanceColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    performanceMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${S.of(context).finalScore}: $totalScore ${S.of(context).of2} $maxRounds",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${S.of(context).percentage}: %$percentage",
                    style: TextStyle(
                      fontSize: 16,
                      color: performanceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(S.of(context).backToMenu),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).playAgain),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      currentRound = 0;
      totalScore = 0;
      isGameStarted = false;
    });
    _loadNewRound();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("${S.of(context).sentenceOrdering} - ${widget.level}"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "$totalScore/$maxRounds",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: !isGameStarted
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildProgressBar(),
          _buildControlButtons(),
          Expanded(child: _buildGameContent()),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("${S.of(context).round} ${currentRound + 1}/$maxRounds"),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentRound / maxRounds,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Listen button (only when cards are not flipped)
          if (!areCardsFlipped)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (canUseListenAttempts &&
                    currentListenAttempts < maxListenAttempts &&
                    !isListening)
                    ? _speakSentencesInOrder
                    : null,
                icon: isListening
                    ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)
                )
                    : const Icon(Icons.volume_up),
                label: Text(
                    isListening
                        ? S.of(context).playingNow
                        : "${S.of(context).listen} (${maxListenAttempts - currentListenAttempts})"
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

          if (!areCardsFlipped) const SizedBox(width: 8),

          // Flip button (only when cards are not flipped)
          if (!areCardsFlipped)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _flipCards,
                icon: const Icon(Icons.flip),
                label: Text(S.of(context).revealSentences),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cards area
          Expanded(
            flex: 3,
            child: GridView.builder(
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
            ),
          ),

          const SizedBox(height: 16),

          // Ordering area
          Expanded(
            flex: 2,
            child: _buildOrderingArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard(Sentence sentence, int index) {
    if (!areCardsFlipped) {
      // Show card back
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
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

    // Show draggable card
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
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                S.of(context).orderSentencesTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Content - Always wrapped in DragTarget
          Expanded(
            child: DragTarget<Sentence>(
              onAccept: _onDragAccept,
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? const Color(0xFF6C63FF)
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: candidateData.isNotEmpty
                        ? const Color(0xFF6C63FF).withOpacity(0.1)
                        : null,
                  ),
                  child: userOrder.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context).dragSentencesHint,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ReorderableListView.builder(
                    onReorder: _onReorderUserOrder,
                    itemCount: userOrder.length,
                    itemBuilder: (context, index) {
                      final sentence = userOrder[index];
                      return Card(
                        key: ValueKey(sentence.id),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6C63FF),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(sentence.text),
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
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: userOrder.length == correctOrder.length ? _checkAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            S.of(context).confirmAnswer,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}