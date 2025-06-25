// screens/story_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

import '../../../../Services/generate_questions_service.dart';
import '../../../../Services/generate_stories_service.dart';
import '../../../../Services/story_score_service.dart';
import 'StoryQuestionsScreen.dart';

class StoryResultScreen extends StatefulWidget {
  final String age, topic, setting, length, goal, role;
  final String? style, heroType, secondaryValues;

  const StoryResultScreen({
    required this.age,
    required this.topic,
    required this.setting,
    required this.length,
    required this.goal,
    required this.role,
    this.style,
    this.heroType,
    this.secondaryValues,
  });

  @override
  _StoryResultScreenState createState() => _StoryResultScreenState();
}

class _StoryResultScreenState extends State<StoryResultScreen>
    with TickerProviderStateMixin {
  final GenerateQuestionsService _questionService = GenerateQuestionsService();
  final StoryDatabaseService _databaseService = StoryDatabaseService();

  // TTS related variables
  FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  // Story generation variables
  String? generatedStory;
  String? currentJobId;
  String storyGenerationStatus = "pending"; // pending, processing, completed, failed, timeout
  String? storyGenerationError;

  List<Question>? questions;
  Map<String, dynamic>? savedStoryData;

  // Loading states
  bool isStoryLoading = true;
  bool isQuestionsLoading = false;
  bool isSavingToDatabase = false;

  // Timer variables
  Timer? _readingTimer;
  Timer? _pollingTimer;
  int _remainingSeconds = 60;
  bool _canAccessQuestions = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _loadingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initTts();
    _generateStory();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadingController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Dynamic duration based on story length
    int timerDuration = _getTimerDuration();
    _progressController = AnimationController(
      duration: Duration(seconds: timerDuration),
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

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  int _getTimerDuration() {
    switch (widget.length.toLowerCase()) {
      case 'قصة قصيرة':
      case 'short':
        return 20;
      case 'قصة متوسطة':
      case 'medium':
        return 40;
      case 'قصة طويلة':
      case 'long':
      default:
        return 60;
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.8);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      if (generatedStory != null && generatedStory!.isNotEmpty) {
        await flutterTts.speak(generatedStory!);
      }
    }
  }

  Future<void> _generateStory() async {
    try {
      setState(() {
        isStoryLoading = true;
        storyGenerationStatus = "pending";
        storyGenerationError = null;
      });

      // Step 1: Start story generation and get job ID
      final String? jobId = await GenerateStoriesService.generateArabicStory(
        age: widget.age,
        topic: widget.topic,
        setting: widget.setting,
        length: widget.length,
        goal: widget.goal,
        heroType: widget.heroType,
        role: widget.role,
      );

      if (jobId == null) {
        setState(() {
          storyGenerationStatus = "failed";
          storyGenerationError = "فشل في بدء توليد القصة";
          isStoryLoading = false;
        });
        _showErrorMessage("فشل في بدء توليد القصة");
        return;
      }

      setState(() {
        currentJobId = jobId;
        storyGenerationStatus = "processing";
      });

      // Step 2: Start polling for story completion
      _startPollingForStory();

    } catch (e) {
      setState(() {
        storyGenerationStatus = "failed";
        storyGenerationError = e.toString();
        isStoryLoading = false;
      });
      _showErrorMessage('حدث خطأ أثناء توليد القصة: $e');
    }
  }

  void _startPollingForStory() {
    if (currentJobId == null) return;

    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        final statusResult = await GenerateStoriesService.getStoryJobStatus(
          jobId: currentJobId!,
          role: widget.role,
        );

        if (statusResult == null) {
          print("Failed to get story status, retrying...");
          return;
        }

        final String status = statusResult["status"] ?? "";
        final String? story = statusResult["story"];
        final String? error = statusResult["error"];

        setState(() {
          storyGenerationStatus = status;
          if (error != null) storyGenerationError = error;
        });

        switch (status) {
          case "completed":
            timer.cancel();
            if (story != null && story.isNotEmpty) {
              setState(() {
                generatedStory = story;
                isStoryLoading = false;
                _remainingSeconds = _getTimerDuration();
              });

              _startReadingTimer();
              _saveStoryToDatabase();
              _generateQuestions();
            } else {
              setState(() {
                storyGenerationStatus = "failed";
                storyGenerationError = "تم إنشاء القصة ولكنها فارغة";
                isStoryLoading = false;
              });
              _showErrorMessage("تم إنشاء القصة ولكنها فارغة");
            }
            break;

          case "failed":
            timer.cancel();
            setState(() {
              isStoryLoading = false;
            });
            _showErrorMessage("فشل في توليد القصة: ${error ?? 'خطأ غير معروف'}");
            break;

          case "pending":
          case "processing":
          // Continue polling
            print("Story generation in progress...");
            break;

          default:
            print("Unknown status: $status");
            break;
        }

      } catch (e) {
        print("Error during polling: $e");
        // Don't stop polling for temporary errors
      }
    });

    // Set a maximum polling timeout (e.g., 60 seconds)
    Timer(Duration(seconds: 60), () {
      if (_pollingTimer?.isActive == true) {
        _pollingTimer?.cancel();
        setState(() {
          storyGenerationStatus = "timeout";
          storyGenerationError = "انتهت مهلة توليد القصة";
          isStoryLoading = false;
        });
        _showErrorMessage("انتهت مهلة توليد القصة. يرجى المحاولة مرة أخرى.");
      }
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _saveStoryToDatabase() async {
    if (generatedStory == null || generatedStory!.isEmpty) return;

    setState(() {
      isSavingToDatabase = true;
    });

    try {
      final storyData = await _databaseService.saveGeneratedStory(
        story: generatedStory!,
        length: widget.length,
        topic: widget.topic,
      );

      setState(() {
        savedStoryData = storyData;
        isSavingToDatabase = false;
      });

      print('Story saved successfully: ${storyData?['id']}');

    } catch (e) {
      setState(() {
        isSavingToDatabase = false;
      });

      print('Error saving story to database: $e');
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

  Widget _buildLoadingScreen() {
    String loadingMessage;
    String loadingDetail;
    IconData loadingIcon;
    Color loadingColor;

    switch (storyGenerationStatus) {
      case "pending":
        loadingMessage = "جاري تحضير القصة...";
        loadingDetail = "يتم الآن تحضير قصتك الخاصة";
        loadingIcon = Icons.hourglass_empty;
        loadingColor = Colors.orange;
        break;
      case "processing":
        loadingMessage = "جاري كتابة قصتك...";
        loadingDetail = "يتم الآن كتابة قصة رائعة خصيصاً لك";
        loadingIcon = Icons.edit;
        loadingColor = Color(0xFF6366F1);
        break;
      case "failed":
        loadingMessage = "فشل في إنشاء القصة";
        loadingDetail = storyGenerationError ?? "حدث خطأ غير متوقع";
        loadingIcon = Icons.error;
        loadingColor = Colors.red;
        break;
      case "timeout":
        loadingMessage = "انتهت مهلة الانتظار";
        loadingDetail = "يرجى المحاولة مرة أخرى";
        loadingIcon = Icons.timer_off;
        loadingColor = Colors.red;
        break;
      default:
        loadingMessage = "جاري المعالجة...";
        loadingDetail = "يرجى الانتظار";
        loadingIcon = Icons.sync;
        loadingColor = Color(0xFF6366F1);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (storyGenerationStatus == "failed" || storyGenerationStatus == "timeout") ...[
                  Icon(
                    loadingIcon,
                    size: 60,
                    color: loadingColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    loadingMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: loadingColor,
                      fontFamily: 'OpenDyslexic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    loadingDetail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'OpenDyslexic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _generateStory(); // Retry
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6366F1),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "إعادة المحاولة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                  ),
                ] else ...[
                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_loadingAnimation.value * 0.2),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: loadingColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            loadingIcon,
                            size: 48,
                            color: loadingColor,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  ),
                  SizedBox(height: 24),
                  Text(
                    loadingMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: 'OpenDyslexic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    loadingDetail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'OpenDyslexic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // if (currentJobId != null) ...[
                  //   SizedBox(height: 16),
                  //   Container(
                  //     padding: EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[100],
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Text(
                  //       "معرف المهمة: ${currentJobId!.substring(0, 8)}...",
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.grey[600],
                  //         fontFamily: 'OpenDyslexic',
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontFamily: 'OpenDyslexic',
                        ),
                      ),
                      Text(
                        "موضوع: ${widget.topic}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'OpenDyslexic',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _toggleSpeech,
                    icon: Icon(
                      isSpeaking ? Icons.stop : Icons.volume_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            if (isSpeaking) ...[
              SizedBox(height: 8),
              Text(
                "جاري القراءة...",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenDyslexic',
                ),
              ),
            ],
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: SingleChildScrollView(
                child: Text(
                  generatedStory ?? 'لم يتم توليد القصة.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 2.2,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'OpenDyslexic',
                    letterSpacing: 0.8,
                    wordSpacing: 2.5,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "نصيحة: اقرأ القصة ببطء وتركيز، يمكنك قراءتها أكثر من مرة أو الاستماع إليها",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontFamily: 'OpenDyslexic',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _canAccessQuestions
                      ? "يمكنك الآن حل الأسئلة"
                      : "اقرأ القصة بعناية - ${_formatTime(_remainingSeconds)}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'OpenDyslexic',
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
        boxShadow: _canAccessQuestions
            ? [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ]
            : [],
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
            Icon(
              _canAccessQuestions ? Icons.quiz : Icons.lock,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              _canAccessQuestions ? "الأسئلة التعليمية 📘" : "الأسئلة مقفلة 🔒",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenDyslexic',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _pollingTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _loadingController.dispose();
    flutterTts.stop();
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
            fontFamily: 'OpenDyslexic',
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            flutterTts.stop();
            _pollingTimer?.cancel();
            Navigator.pop(context);
          },
        ),
      ),
      body: isStoryLoading
          ? _buildLoadingScreen()
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