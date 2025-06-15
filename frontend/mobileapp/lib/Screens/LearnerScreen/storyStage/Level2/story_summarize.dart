import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../../../../Services/story_score_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRandomStories();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadRandomStories() async {
    setState(() {
      _isLoadingStories = true;
    });

    try {
      // Get learner ID from SharedPreferences or use a default
      final prefs = await SharedPreferences.getInstance();
      String learnerId = prefs.getString('userId') ?? '676579893a5c2ad7d653448a'; // Default learner ID

      // Get random stories with summaries
      Map<String, dynamic>? result = await _storyService.getRandomStoriesWithSummaries(learnerId);

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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: suggestions.map<Widget>((suggestion) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion.toString(),
                          textAlign: TextAlign.right,
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
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  void _selectQuizAnswer(int index) {
    if (_quizAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _quizAnswered = true;
      _showQuizResult = true;
    });
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
            onPressed: () {
              setState(() {
                _summaryController.clear();
                _feedbackMessage = null;
              });
              _resetQuiz();
              _loadRandomStories();
            },
          ),
        ],
      ),
      body: _isLoadingStories
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'جاري تحميل القصص...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Story Display Card
            if (_mainStory != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.book_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'القصة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              _mainStory!['kind'] ?? 'قصة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _mainStory!['story'],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      if (_mainStory!['morale'] != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'الدرس المستفاد: ${_mainStory!['morale']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
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

              // Summary Input Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FD1C7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF4FD1C7),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'اكتب ملخصك هنا',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _summaryController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'اكتب ملخصاً للقصة يتضمن الأحداث الرئيسية والشخصيات والدرس المستفاد...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(15),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Feedback Message
              if (_feedbackMessage != null)
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _feedbackColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _feedbackColor ?? Colors.grey,
                      width: 1,
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
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),

              // Check Summary Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FD1C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'جاري التحقق...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 10),
                      Text(
                        'تحقق من الملخص',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Quiz Section
              if (_quizOptions.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.quiz_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'اختبار سريع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أي من الملخصات التالية يناسب القصة التي قرأتها؟',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 15),
                              ...List.generate(_quizOptions.length, (index) {
                                bool isSelected = _selectedAnswerIndex == index;
                                bool isCorrect = index == _correctAnswerIndex;
                                bool showResult = _showQuizResult;

                                Color? cardColor;
                                if (showResult) {
                                  if (isCorrect) {
                                    cardColor = Colors.green.withOpacity(0.2);
                                  } else if (isSelected && !isCorrect) {
                                    cardColor = Colors.red.withOpacity(0.2);
                                  }
                                }

                                return GestureDetector(
                                  onTap: () => _selectQuizAnswer(index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardColor ?? (isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: showResult
                                            ? (isCorrect ? Colors.green : (isSelected && !isCorrect ? Colors.red : Colors.grey))
                                            : (isSelected ? Colors.blue : Colors.grey),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (showResult) ...[
                                          Icon(
                                            isCorrect ? Icons.check_circle : (isSelected && !isCorrect ? Icons.cancel : Icons.radio_button_unchecked),
                                            color: isCorrect ? Colors.green : (isSelected && !isCorrect ? Colors.red : Colors.grey),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: Text(
                                            _quizOptions[index],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF2D3748),
                                            ),
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (_showQuizResult) ...[
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _resetQuiz,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              ],
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