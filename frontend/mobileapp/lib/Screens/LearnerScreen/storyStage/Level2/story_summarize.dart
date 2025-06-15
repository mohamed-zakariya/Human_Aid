import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../../../../Services/story_score_service.dart';
import '../../../../Services/add_score_service.dart'; // Add this import
import '../../../../generated/l10n.dart';

class ArabicStorySummarizeWidget extends StatefulWidget {
  const ArabicStorySummarizeWidget({Key? key}) : super(key: key);

  @override
  State<ArabicStorySummarizeWidget> createState() => _ArabicStorySummarizeWidgetState();
}

class _ArabicStorySummarizeWidgetState extends State<ArabicStorySummarizeWidget> {
  final TextEditingController _summaryController = TextEditingController();
  final StoryDatabaseService _storyService = StoryDatabaseService();

  bool _isLoading = false;
  bool _isLoadingStories = true;
  String? _feedbackMessage;
  Color? _feedbackColor;

  // Story data
  Map<String, dynamic>? _mainStory;
  List<Map<String, dynamic>> _allStories = [];
  List<String?> _allSummaries = [];

  // Quiz data
  List<String> _quizOptions = [];
  int _correctAnswerIndex = -1;
  int? _selectedAnswerIndex;
  bool _showQuizResult = false;
  bool _quizAnswered = false;

  FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isLoadingTts = false;


  @override
  void initState() {
    super.initState();
    _loadRandomStories();
    _initTts(); // Add this line
  }

  @override
  void dispose() {
    _summaryController.dispose();
    flutterTts.stop(); // Add this line
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _isLoadingTts = false;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _isLoadingTts = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _isLoadingTts = false;
      });
    });
  }

  // Add this method for speaking text
  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _isLoadingTts = false;
      });
    } else {
      setState(() {
        _isLoadingTts = true;
      });
      await flutterTts.speak(text);
    }
  }

  // Add this method to get color based on story kind
  Color _getStoryKindColor(String? kind) {
    if (kind == null) return Colors.grey;

    switch (kind) {
      case 'قصة قصيرة':
        return Colors.green;
      case 'قصة متوسطة':
        return Colors.yellow[700]!;
      case 'قصة طويلة':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  Future<void> _loadRandomStories() async {
    setState(() {
      _isLoadingStories = true;
    });

    try {
      // Get learner ID from SharedPreferences or use a default
      final prefs = await SharedPreferences.getInstance();
      String? learnerId = prefs.getString('userId'); // Default learner ID

      // Get random stories with summaries
      Map<String, dynamic>? result = await _storyService.getRandomStoriesWithSummaries(learnerId!);

      if (result != null) {
        setState(() {
          _mainStory = result['main_story'];
          _allStories = List<Map<String, dynamic>>.from(result['all_stories']);
          _allSummaries = List<String?>.from(result['summaries']);
          _isLoadingStories = false;
        });

        _setupQuiz();
      } else {
        throw Exception('لم يتم العثور على قصص');
      }
    } catch (e) {
      setState(() {
        _isLoadingStories = false;
        _feedbackMessage = 'خطأ في تحميل القصص: ${e.toString()}';
        _feedbackColor = Colors.red;
      });
    }
  }

  void _setupQuiz() {
    if (_allSummaries.isEmpty || _allSummaries.any((summary) => summary == null)) {
      return;
    }

    // Create quiz options with the summaries
    _quizOptions = _allSummaries.map((summary) => summary!).toList();

    // Shuffle the options but remember the correct answer position
    _correctAnswerIndex = 0; // The main story is always the first one

    // Create a list of indices and shuffle them
    List<int> indices = List.generate(_quizOptions.length, (index) => index);
    indices.shuffle();

    // Reorder options and find new correct answer index
    List<String> shuffledOptions = [];
    for (int i = 0; i < indices.length; i++) {
      shuffledOptions.add(_quizOptions[indices[i]]);
      if (indices[i] == 0) {
        _correctAnswerIndex = i;
      }
    }

    _quizOptions = shuffledOptions;
  }

  void _checkSummary() async {
    if (_summaryController.text.trim().isEmpty) {
      setState(() {
        _feedbackMessage = 'يرجى كتابة ملخص للقصة';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    if (_mainStory == null) {
      setState(() {
        _feedbackMessage = 'لا توجد قصة متاحة للتحقق';
        _feedbackColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    try {
      final result = await _performLocalValidation(
          _summaryController.text.trim(),
          _mainStory!['story']
      );

      setState(() {
        _isLoading = false;
        if (result['is_valid'] == true) {
          _feedbackMessage = '${result['feedback']} (النتيجة: ${result['score']}%)';
          _feedbackColor = result['score'] >= 75 ? Colors.green : Colors.blue;
        } else {
          _feedbackMessage = '${result['feedback']} (النتيجة: ${result['score']}%)';
          _feedbackColor = Colors.orange;
        }
      });

      // Show suggestions if available
      if (result['suggestions'] != null && result['suggestions'].isNotEmpty) {
        _showSuggestionsDialog(result['suggestions']);
      }

    } catch (e) {
      setState(() {
        _feedbackMessage = 'حدث خطأ أثناء فحص الملخص: ${e.toString()}';
        _feedbackColor = Colors.red;
        _isLoading = false;
      });
    }
  }

  // Simple local validation
  Map<String, dynamic> _performLocalValidation(String userSummary, String originalStory) {
    if (userSummary.length < 20) {
      return {
        'is_valid': false,
        'score': 30,
        'feedback': 'الملخص قصير جداً. حاول إضافة المزيد من التفاصيل المهمة.',
        'suggestions': ['أضف الشخصيات الرئيسية', 'اذكر الأحداث المهمة', 'أضف النتيجة أو الدرس المستفاد']
      };
    }

    if (userSummary.length > 200) {
      return {
        'is_valid': false,
        'score': 60,
        'feedback': 'الملخص طويل جداً. حاول التركيز على النقاط الأساسية فقط.',
        'suggestions': ['اختصر الأحداث الثانوية', 'ركز على الفكرة الرئيسية', 'احذف التفاصيل غير المهمة']
      };
    }

    // Basic keyword validation
    List<String> commonWords = ['في', 'من', 'إلى', 'على', 'مع', 'بعد', 'قبل', 'هذا', 'ذلك'];
    List<String> userWords = userSummary.split(' ').where((word) =>
    word.length > 2 && !commonWords.contains(word)).toList();
    List<String> storyWords = originalStory.split(' ').where((word) =>
    word.length > 2 && !commonWords.contains(word)).toList();

    int matchCount = 0;
    for (String userWord in userWords) {
      if (storyWords.any((storyWord) => storyWord.contains(userWord) || userWord.contains(storyWord))) {
        matchCount++;
      }
    }

    double score = userWords.isNotEmpty ? (matchCount / userWords.length) * 100 : 0;

    if (score >= 60) {
      return {
        'is_valid': true,
        'score': score.round(),
        'feedback': 'ممتاز! ملخص جيد يغطي النقاط الأساسية للقصة.',
        'suggestions': []
      };
    } else if (score >= 40) {
      return {
        'is_valid': true,
        'score': score.round(),
        'feedback': 'جيد! لكن يمكن تحسين الملخص بإضافة المزيد من التفاصيل المهمة.',
        'suggestions': ['أضف المزيد من الأحداث الرئيسية', 'اذكر النتيجة أو الدرس المستفاد']
      };
    } else {
      return {
        'is_valid': false,
        'score': score.round(),
        'feedback': 'الملخص يحتاج إلى تحسين. لم يغطِ النقاط الأساسية للقصة.',
        'suggestions': ['اقرأ القصة مرة أخرى', 'ركز على الشخصيات الرئيسية', 'اذكر الأحداث المهمة']
      };
    }
  }

  void _showSuggestionsDialog(List<dynamic> suggestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'اقتراحات للتحسين',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: suggestions.map<Widget>((suggestion) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion.toString(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF7B68EE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectQuizAnswer(int index) async {
    if (_quizAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _quizAnswered = true;
      _showQuizResult = true;
    });

    // Update score based on answer
    bool isCorrect = index == _correctAnswerIndex;
    int score = isCorrect ? 10 : 5;

    try {
      await AddScoreService.updateScore(
        score: score,
        outOf: 10, // Total possible score
      );
    } catch (e) {
      print('Error updating score: $e');
    }

    // Show result dialog
    _showQuizResultDialog(isCorrect);
  }

  void _showQuizResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isCorrect ? Colors.green : Colors.orange).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.celebration : Icons.lightbulb,
                  size: 60,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isCorrect ? '🎉 مبروك! 🎉' : '💡 تعلم واكتشف 💡',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Message
              Text(
                isCorrect
                    ? 'أحسنت! إجابتك صحيحة تماماً!\nلقد حصلت على 10 نقاط'
                    : 'لا بأس، يمكنك المحاولة مرة أخرى!\nحصلت على 5 نقاط للمحاولة',
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),

              // Show correct answer if wrong
              if (!isCorrect) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الإجابة الصحيحة:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quizOptions[_correctAnswerIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Try Again Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadNewStory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B68EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'قصة جديدة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Continue Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (!isCorrect) {
                        _resetQuiz();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCorrect ? Colors.green : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCorrect ? 'متابعة' : 'حاول مرة أخرى',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  void _loadNewStory() {
    setState(() {
      _summaryController.clear();
      _feedbackMessage = null;
      _selectedAnswerIndex = null;
      _showQuizResult = false;
      _quizAnswered = false;
    });
    _loadRandomStories();
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswerIndex = null;
      _showQuizResult = false;
      _quizAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          args['gameName'] ?? 'تلخيص القصص',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF7B68EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNewStory,
            tooltip: 'قصة جديدة',
          ),
        ],
      ),
      body: _isLoadingStories
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B68EE)),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل القصص...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Story Display Card (Dyslexic-friendly)
            if (_mainStory != null) ...[
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C88FF), Color(0xFF7B68EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.book_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'القصة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Add TTS button for story
                          GestureDetector(
                            onTap: () => _speak(_mainStory!['story']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isLoadingTts
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Icon(
                                _isSpeaking ? Icons.stop : Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStoryKindColor(_mainStory!['kind']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _mainStory!['kind'] ?? 'قصة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Dyslexic-friendly story text
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5), // Cream background
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _mainStory!['story'],
                          style: const TextStyle(
                            fontSize: 18, // Larger font size
                            height: 2.0, // Increased line spacing
                            color: Color(0xFF2D3748),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5, // Better letter spacing
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      if (_mainStory!['morale'] != null) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'الدرس المستفاد: ${_mainStory!['morale']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Feedback Message
              if (_feedbackMessage != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: _feedbackColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _feedbackColor ?? Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _feedbackColor == Colors.green
                            ? Icons.check_circle_outline
                            : _feedbackColor == Colors.blue
                            ? Icons.thumb_up_outlined
                            : _feedbackColor == Colors.red
                            ? Icons.error_outline
                            : Icons.info_outline,
                        color: _feedbackColor,
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),

              // Quiz Section
              if (_quizOptions.isNotEmpty) ...[
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9A8B), Color(0xFFFE7A9B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.quiz_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              'اختبار سريع',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أي من الملخصات التالية يناسب القصة التي قرأتها؟',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 20),
                              ...List.generate(_quizOptions.length, (index) {
                                bool isSelected = _selectedAnswerIndex == index;
                                bool isCorrect = index == _correctAnswerIndex;
                                bool showResult = _showQuizResult;

                                Color? cardColor;
                                Color borderColor = Colors.grey;
                                if (showResult) {
                                  if (isCorrect) {
                                    cardColor = Colors.green.withOpacity(0.2);
                                    borderColor = Colors.green;
                                  } else if (isSelected && !isCorrect) {
                                    cardColor = Colors.red.withOpacity(0.2);
                                    borderColor = Colors.red;
                                  }
                                } else if (isSelected) {
                                  cardColor = Colors.blue.withOpacity(0.1);
                                  borderColor = Colors.blue;
                                }

                                return GestureDetector(
                                  onTap: () => _selectQuizAnswer(index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: cardColor ?? Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (showResult) ...[
                                          Icon(
                                            isCorrect ? Icons.check_circle : (isSelected && !isCorrect ? Icons.cancel : Icons.radio_button_unchecked),
                                            color: isCorrect ? Colors.green : (isSelected && !isCorrect ? Colors.red : Colors.grey),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 15),
                                        ],
                                        Expanded(
                                          child: Text(
                                            _quizOptions[index],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF2D3748),
                                              height: 1.8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Add TTS button for each quiz option
                                        GestureDetector(
                                          onTap: () => _speak(_quizOptions[index]),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.volume_up,
                                              color: Color(0xFF2D3748),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}