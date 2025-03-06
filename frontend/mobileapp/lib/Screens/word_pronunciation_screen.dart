import 'dart:async';
import 'package:flutter/material.dart';
import '../services/words_service.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../models/learner.dart';
import '../models/word.dart';

class WordPronunciationScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange;
  
  const WordPronunciationScreen({ 
    super.key, 
    this.onLocaleChange,
  });

  @override
  _WordPronunciationScreenState createState() => _WordPronunciationScreenState();
}

class _WordPronunciationScreenState extends State<WordPronunciationScreen> {
  // The list of letters that make up the current word
  List<String> _wordLetters = [];

  // The current word fetched from the database
  String _currentWord = "";
  String _currentWordId = ""; // Add ID to track the current word

  int _attemptsLeft = 3;
  
  // User info
  Learner? _learner;
  String _username = "";
  String _userId = ""; // Add user ID for backend requests

  // Audio service
  final AudioService _audioService = AudioService();
  
  // Exercise info
  String _exerciseId = "67c66a0e3387a31ba1ee4a72"; // Replace with actual exercise ID from navigation args

  // Recording configuration
  static const int _maxRecordingSeconds = 30;
  int _timerSeconds = 0;
  Timer? _timer;
  bool _isRecording = false;
  
  // Feedback state
  bool _isProcessing = false;
  String _feedbackMessage = "";
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _loadWord(); // Fetch the first word on screen load
    
    // Get the learner info passed as arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Learner) {
        setState(() {
          _learner = args;
          _username = _learner?.name ?? "User";
          _userId = _learner?.id ?? "user123"; // Get user ID from learner model
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  /// Fetch a random word from the database
// In WordPronunciationScreen

Future<void> _loadWord() async {
  setState(() {
    _isProcessing = true;
    _feedbackMessage = "";
    _isCorrect = null;
  });
  
  // This now returns a Word? instead of a String?
  final Word? fetchedWord = await WordsService.fetchRandomWord("Beginner");

  if (fetchedWord == null) {
    // Handle "no words" scenario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("لا توجد كلمات في هذا المستوى.")),
    );
    setState(() {
      _isProcessing = false;
    });
    return;
  }

  // We got a valid Word with real MongoDB _id
  setState(() {
    _currentWord = fetchedWord.text;    // text = "قمر" or "تفاحة", etc.
    _currentWordId = fetchedWord.id;    // e.g. "6427fae2fd720055f811029d"
    _wordLetters = fetchedWord.text.split('');
    _isProcessing = false;
  });
}


  /// Start recording + timer
  void _startRecording() async {
    try {
      await _audioService.startRecording();
      
      setState(() {
        _isRecording = true;
        _timerSeconds = 0;
        _feedbackMessage = "";
        _isCorrect = null;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _timerSeconds++);
        if (_timerSeconds >= _maxRecordingSeconds) {
          _stopRecording();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("انتهى الوقت المسموح للتسجيل!")),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في بدء التسجيل: $e")),
      );
    }
  }

  /// Stop recording + timer
  Future<String?> _stopRecording() async {
    _timer?.cancel();
    setState(() => _isRecording = false);
    return await _audioService.stopRecording();
  }

  void _onRecordButtonPressed() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _onWrongButtonPressed() async {
    // Discard recording if needed
    if (_isRecording) {
      final audioPath = await _stopRecording();
      // We don't process the audio in this case, just discard it
      setState(() {
        _feedbackMessage = "تم تجاهل التسجيل";
      });
    }
  }

  void _onCorrectButtonPressed() async {
    // Process recording if available
    if (_isRecording) {
      final audioPath = await _stopRecording();
      if (audioPath != null) {
        _processSpeech(audioPath);
      }
    }
  }

  /// Process the speech recording
  Future<void> _processSpeech(String audioPath) async {
    setState(() {
      _isProcessing = true;
      _feedbackMessage = "جاري معالجة التسجيل...";
    });

    try {
      final result = await SpeechService.processSpeech(
        userId: _userId,
        exerciseId: _exerciseId,
        wordId: _currentWordId,
        audioFilePath: audioPath,
      );

      if (result != null) {
        setState(() {
          _isProcessing = false;
          _feedbackMessage = result['message'];
          _isCorrect = result['isCorrect'];
          
          // Update attempts if incorrect
          if (!result['isCorrect']) {
            _attemptsLeft = _attemptsLeft > 0 ? _attemptsLeft - 1 : 0;
          }
        });
        
        // If out of attempts, show message and load next word after delay
        if (_attemptsLeft == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("انتهت المحاولات! سننتقل للكلمة التالية...")),
          );
          
          Future.delayed(const Duration(seconds: 3), () {
            _loadWord();
            setState(() {
              _attemptsLeft = 3; // Reset attempts for next word
            });
          });
        }
      } else {
        setState(() {
          _isProcessing = false;
          _feedbackMessage = "حدث خطأ أثناء معالجة التسجيل";
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _feedbackMessage = "خطأ: $e";
      });
    }
  }

  /// When "التالي" is pressed, fetch a new word
  void _onNextButtonPressed() {
    _loadWord(); 
    setState(() {
      _attemptsLeft = 3; // Reset attempts
    });
  }

  /// Format seconds as mm:ss
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Single method to build each letter card
  Widget _buildLetterCard(String letter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Build feedback widget based on processing state
  Widget _buildFeedback() {
    if (_isProcessing) {
      return const CircularProgressIndicator();
    }
    
    if (_feedbackMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isCorrect == true 
              ? Colors.green.withOpacity(0.2) 
              : _isCorrect == false 
                  ? Colors.red.withOpacity(0.2) 
                  : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _feedbackMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isCorrect == true 
                ? Colors.green 
                : _isCorrect == false 
                    ? Colors.red 
                    : Colors.black87,
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6E3EB),
        elevation: 0,
        title: Column(
          children: [
            const Text(
              'المرحلة الثانية • المستوى الأول',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Display username
            Text(
              'مرحباً $_username',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD6E3EB),
              Color(0xFFF2B3B4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Image
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/Apple.png', height: 150),
                  ],
                ),
              ),

              // Word text
              const SizedBox(height: 10),
              Text(
                _currentWord,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Attempts text
              Column(
                children: [
                  const Text(
                    'لا تخف لا داعي للقلق',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'متبقي لك $_attemptsLeft محاولات',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              
              // Feedback message
              _buildFeedback(),

              const SizedBox(height: 10),

              // Timer + Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _isRecording
                            ? (_timerSeconds / _maxRecordingSeconds)
                            : 0,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_timerSeconds),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Letters displayed right-to-left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  textDirection: TextDirection.rtl, // Ensures RTL layout
                  spacing: 8,                       // Horizontal space
                  runSpacing: 12,                   // Vertical space if wrapping
                  alignment: WrapAlignment.center,
                  children: _wordLetters
                      .map((letter) => _buildLetterCard(letter))
                      .toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Control buttons (Wrong, Record, Correct)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Wrong (X) if recording
                  if (_isRecording)
                    OutlinedButton(
                      onPressed: _onWrongButtonPressed,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: const BorderSide(width: 2, color: Colors.red),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),

                  if (_isRecording) const SizedBox(width: 24),

                  // Record or Stop
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _onRecordButtonPressed,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.white,
                      elevation: 3,
                      foregroundColor: Colors.grey,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isRecording ? Colors.black : Colors.red,
                      size: 32,
                    ),
                  ),

                  if (_isRecording) const SizedBox(width: 24),

                  // Correct (✓) if recording
                  if (_isRecording)
                    OutlinedButton(
                      onPressed: _onCorrectButtonPressed,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: const BorderSide(width: 2, color: Colors.green),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Next button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _onNextButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}