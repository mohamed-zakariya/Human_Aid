// screens/story_result_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../Services/generate_stories_service.dart';
import '../../../Services/generate_questions_service.dart';
import 'StoryQuestionsScreen.dart';

class StoryResultScreen extends StatefulWidget {
  final String age, topic, setting, length, goal;
  final String? style, heroType, secondaryValues;

  const StoryResultScreen({
    required this.age,
    required this.topic,
    required this.setting,
    required this.length,
    required this.goal,
    this.style,
    this.heroType,
    this.secondaryValues,
  });

  @override
  _StoryResultScreenState createState() => _StoryResultScreenState();
}

class _StoryResultScreenState extends State<StoryResultScreen>
    with TickerProviderStateMixin {
  final GenerateStoriesService _storyService = GenerateStoriesService();
  final GenerateQuestionsService _questionService = GenerateQuestionsService();

  String? generatedStory;
  List<Question>? questions;
  bool isStoryLoading = true;
  bool isQuestionsLoading = false;

  // Timer variables
  Timer? _readingTimer;
  int _remainingSeconds = 60; // 60 seconds reading time
  bool _canAccessQuestions = false;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateStory();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
  }

  Future<void> _generateStory() async {
    try {
      final story = await _storyService.generateArabicStory(
        age: widget.age,
        topic: widget.topic,
        setting: widget.setting,
        length: widget.length,
        goal: widget.goal,
        style: widget.style,
        heroType: widget.heroType,
        secondaryValues: widget.secondaryValues,
      );

      setState(() {
        generatedStory = story;
        isStoryLoading = false;
      });

      // Start reading timer and generate questions in background
      _startReadingTimer();
      _generateQuestions();
    } catch (e) {
      setState(() {
        isStoryLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء توليد القصة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startReadingTimer() {
    _progressController.forward();
    _readingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _canAccessQuestions = true;
        });
        _pulseController.stop();
      }
    });
  }

  Future<void> _generateQuestions() async {
    if (generatedStory == null) return;

    setState(() {
      isQuestionsLoading = true;
    });

    try {
      final generatedQuestions = await _questionService.generateQuestionsFromStory(generatedStory!);
      setState(() {
        questions = generatedQuestions;
        isQuestionsLoading = false;
      });
    } catch (e) {
      setState(() {
        isQuestionsLoading = false;
      });
      print('Error generating questions: $e');
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStoryCard() {
    return Container(
      margin: EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_stories, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "قصتك الخاصة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        "موضوع: ${widget.topic}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                generatedStory ?? 'لم يتم توليد القصة.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _canAccessQuestions
              ? [Color(0xFF10B981), Color(0xFF059669)]
              : [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_canAccessQuestions ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _canAccessQuestions ? 1.0 : _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _canAccessQuestions ? Icons.check_circle : Icons.timer,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _canAccessQuestions ? "وقت القراءة انتهى!" : "وقت القراءة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _canAccessQuestions
                      ? "يمكنك الآن حل الأسئلة"
                      : "اقرأ القصة بعناية - ${_formatTime(_remainingSeconds)}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (!_canAccessQuestions) ...[
                  SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsButton() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _canAccessQuestions
              ? [Color(0xFF6366F1), Color(0xFF8B5CF6)]
              : [Colors.grey[400]!, Colors.grey[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _canAccessQuestions ? [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: _canAccessQuestions && questions != null
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryQuestionsScreen(
                story: generatedStory!,
                questions: questions!,
              ),
            ),
          );
        }
            : null,
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
            if (isQuestionsLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "جاري تحضير الأسئلة...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Icon(
                _canAccessQuestions ? Icons.quiz : Icons.lock,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                _canAccessQuestions ? "الأسئلة التعليمية 📘" : "الأسئلة مقفلة 🔒",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "القصة الناتجة",
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
      ),
      body: isStoryLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "جاري كتابة قصتك الخاصة...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "سيتم إنشاء قصة رائعة خصيصاً لك",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildStoryCard(),
            _buildTimerCard(),
            _buildQuestionsButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}