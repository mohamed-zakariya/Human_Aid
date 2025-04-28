import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceTest/quizapp.dart';

class Test {
  final String title;
  final double unlockThreshold;
  final int index;

  Test({required this.title, required this.unlockThreshold, required this.index});
}

class TestSelectorWidget extends StatefulWidget {
  final double userProgress;

  TestSelectorWidget({required this.userProgress});

  @override
  _TestSelectorWidgetState createState() => _TestSelectorWidgetState();
}

class _TestSelectorWidgetState extends State<TestSelectorWidget> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _offsetAnimations;

  final List<Test> tests = [
    Test(title: "اختبار 1", unlockThreshold: 0.1, index: 1),
    Test(title: "اختبار 2", unlockThreshold: 0.2, index: 2),
    Test(title: "اختبار 3", unlockThreshold: 0.3, index: 3),
    Test(title: "اختبار 4", unlockThreshold: 0.4, index: 4),
    Test(title: "اختبار 5", unlockThreshold: 0.5, index: 5),
    Test(title: "اختبار 6", unlockThreshold: 0.6, index: 6),
    Test(title: "اختبار 7", unlockThreshold: 0.7, index: 7),
    Test(title: "اختبار 8", unlockThreshold: 0.8, index: 8),
    Test(title: "اختبار 9", unlockThreshold: 0.9, index: 9),
  ];

  final List<Color> unlockedColors = [
    Colors.teal,
    Colors.deepPurple,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.blueAccent,
  ];


  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      tests.length,
          (i) => AnimationController(
        duration: Duration(milliseconds: 500 + (i * 100)),
        vsync: this,
      ),
    );

    _offsetAnimations = List.generate(tests.length, (i) {
      final begin = i % 2 == 0 ? Offset(-1, 0) : Offset(1, 0); // Even: left, Odd: right
      return Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeOut,
      ));
    });

    // Trigger animations with a delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE2E8F0),
        elevation: 0,
        title: const Text(
          "الاختبارات",
          style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E293B),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "معلومات عن الاختبارات",
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "سيتم فتح كل اختبار بناءً على نسبة التقدم في الدورة.\n"
                              "مثال:\n"
                              "- اختبار 1 يفتح عند 10٪\n"
                              "- اختبار 2 يفتح عند 20٪\n"
                              "وهكذا حتى 90٪.",
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              "فهمت",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            final isUnlocked = widget.userProgress >= test.unlockThreshold;

            return SlideTransition(
              position: _offsetAnimations[index],
              child: GestureDetector(
                onTap: isUnlocked
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizPage(testNumber: test.index)),
                  );
                }
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? unlockedColors[index % unlockedColors.length]
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        color: const Color(0xFFE2E8F0),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.title,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: widget.userProgress,
                              backgroundColor: const Color(0xFF334155),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUnlocked
                                    ? Colors.greenAccent
                                    : const Color(0xFFF43F5E),
                              ),
                              minHeight: 6,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUnlocked
                                  ? "تم فتح هذا الاختبار"
                                  : "يُفتح عند تقدمك إلى ${(test.unlockThreshold * 100).toInt()}%",
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
