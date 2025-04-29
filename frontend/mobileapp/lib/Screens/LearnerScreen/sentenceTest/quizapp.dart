import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceTest/transpiled_answer.dart';
import 'quiz_header.dart';
import 'answer_options.dart';

class QuizPage extends StatefulWidget {
  final int testNumber; // which test this is

  QuizPage({required this.testNumber});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Map<String, dynamic>> questions = [
    {
      "question": "ما الكلمة الأنسب لإكمال الجملة: ذهب أحمد إلى ___ لشراء الخبز؟",
      "options": ["المدرسة", "المخبز", "المستشفى", "المطار"],
      "answer": "المخبز",
    },
    {
      "question": "ما معنى كلمة 'ضجيج'؟",
      "options": ["هدوء", "صوت مرتفع", "كلام لطيف", "صمت"],
      "answer": "صوت مرتفع",
    },
    {
      "question": "أي الجمل التالية تدل على شعور بالحزن؟",
      "options": [
        "ضحك الطفل بصوت عالٍ",
        "بكى الولد بعد سماع الخبر",
        "احتفل الجميع في العيد",
        "ابتسمت الأم لابنها"
      ],
      "answer": "بكى الولد بعد سماع الخبر",
    },
  ];

  int currentIndex = 0;
  String? selectedAnswer;
  bool isSubmitted = false;

  void _submitAnswer() {
    setState(() => isSubmitted = true);
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        isSubmitted = false;
      });
    } else {
      // All questions are completed
      _markTestAsCompleted(widget.testNumber);

      // You can show a completion screen or reward here
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("تم إكمال الاختبار ✅"),
          content: const Text("أحسنت! لقد أكملت الاختبار بنجاح."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("الرجوع"),
            )
          ],
        ),
      );
    }
  }

  void _markTestAsCompleted(int testNumber) {
    // TODO: Update user progress in backend or local database
    print("Test $testNumber completed ✅");
    // e.g., FirebaseFirestore.instance.collection('users').doc(userId).update({...})
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B3A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  QuestionHeader(
                    question: current["question"],
                    index: currentIndex,
                    total: questions.length,
                  ),
                  const SizedBox(height: 10),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: (currentIndex + (isSubmitted ? 1 : 0)) / questions.length,
                    backgroundColor: Colors.white24,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 20),

                  // Answer options
                  Column(
                    children: (current["options"] as List<String>).map((option) {
                      return AnswerOption(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: current["answer"] == option,
                        isSubmitted: isSubmitted,
                        onTap: () {
                          if (!isSubmitted) {
                            setState(() => selectedAnswer = option);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Show correct answer
                  if (isSubmitted)
                    TranspiledAnswer(correctAnswer: current["answer"]),

                  const SizedBox(height: 30),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: selectedAnswer != null ? _submitAnswer : null,
                        child: const Text("تحقق"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isSubmitted)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text(currentIndex < questions.length - 1 ? "التالي" : "إنهاء"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
