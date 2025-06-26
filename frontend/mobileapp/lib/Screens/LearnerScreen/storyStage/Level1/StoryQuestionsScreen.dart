// screens/story_questions_screen.dart
import 'package:flutter/material.dart';

import '../../../../Services/add_score_service.dart';
import '../../../../Services/generate_questions_service.dart';
import '../../../../models/questions.dart';

class StoryQuestionsScreen extends StatefulWidget {
  final String story;
  final List<Question> questions;

  StoryQuestionsScreen({
    required this.story,
    required this.questions,
  });

  @override
  _StoryQuestionsScreenState createState() => _StoryQuestionsScreenState();
}

class _StoryQuestionsScreenState extends State<StoryQuestionsScreen>
    with TickerProviderStateMixin {
  List<int?> selectedAnswers = [];
  bool showResults = false;
  int score = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.questions.length, null);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _selectAnswer(int questionIndex, int answerIndex) {
    setState(() {
      selectedAnswers[questionIndex] = answerIndex;
    });
  }

  void _submitAnswers() async {
    if (selectedAnswers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى الإجابة على جميع الأسئلة'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Calculate score
    score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == widget.questions[i].correctIndex) {
        score++;
      }
    }

    try {
      // Submit the score
      await AddScoreService.updateScore(
        score: score,
        outOf: widget.questions.length,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حفظ النتيجة'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      showResults = true;
    });
  }


  Color _getScoreColor() {
    double percentage = score / widget.questions.length;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage() {
    double percentage = score / widget.questions.length;
    if (percentage >= 0.8) return "ممتاز! أحسنت 🎉";
    if (percentage >= 0.6) return "جيد جداً! 👍";
    return "حاول مرة أخرى 💪";
  }

  Widget _buildQuestionCard(int index, Question question) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Answer Options
            ...List.generate(question.choices.length, (choiceIndex) {
              bool isSelected = selectedAnswers[index] == choiceIndex;
              bool isCorrect = question.correctIndex == choiceIndex;
              bool showCorrectAnswer = showResults && isCorrect;
              bool showWrongAnswer = showResults && isSelected && !isCorrect;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: showCorrectAnswer
                        ? [Colors.green.shade100, Colors.green.shade50]
                        : showWrongAnswer
                        ? [Colors.red.shade100, Colors.red.shade50]
                        : isSelected
                        ? [Color(0xFF6366F1).withOpacity(0.1), Color(0xFF8B5CF6)
                        .withOpacity(0.1)
                    ]
                        : [Colors.grey.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: showCorrectAnswer
                        ? Colors.green
                        : showWrongAnswer
                        ? Colors.red
                        : isSelected
                        ? Color(0xFF6366F1)
                        : Colors.grey.shade300,
                    width: showResults ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: showCorrectAnswer
                          ? Colors.green
                          : showWrongAnswer
                          ? Colors.red
                          : isSelected
                          ? Color(0xFF6366F1)
                          : Colors.grey.shade300,
                    ),
                    child: Icon(
                      showCorrectAnswer
                          ? Icons.check
                          : showWrongAnswer
                          ? Icons.close
                          : isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: showResults || isSelected ? Colors.white : Colors
                          .grey[600],
                      size: 16,
                    ),
                  ),
                  title: Text(
                    question.choices[choiceIndex],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .normal,
                      color: showCorrectAnswer
                          ? Colors.green.shade800
                          : showWrongAnswer
                          ? Colors.red.shade800
                          : Colors.grey[800],
                    ),
                  ),
                  onTap: showResults
                      ? null
                      : () => _selectAnswer(index, choiceIndex),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor().withOpacity(0.1),
            _getScoreColor().withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getScoreColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor().withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getScoreColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score/${widget.questions.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            _getScoreMessage(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'حصلت على $score من ${widget.questions.length} إجابات صحيحة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedAnswers =
                          List.filled(widget.questions.length, null);
                      showResults = false;
                      score = 0;
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.home),
                  label: Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'أسئلة حول القصة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!showResults)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${selectedAnswers
                      .where((answer) => answer != null)
                      .length}/${widget.questions.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (showResults) _buildResultsCard(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(index, widget.questions[index]);
                },
              ),
            ),
            if (!showResults)
              Container(
                padding: EdgeInsets.all(16),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: selectedAnswers.contains(null)
                          ? [Colors.grey[400]!, Colors.grey[500]!]
                          : [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: !selectedAnswers.contains(null) ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ] : [],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'إرسال الإجابات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}