// word_pronunciation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/widgets/feedback_widget.dart';
import 'package:mobileapp/Screens/widgets/letters_widget.dart';
import 'package:mobileapp/Screens/widgets/recording_controls.dart';
import 'package:mobileapp/Screens/widgets/timer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import '../../models/learner.dart';
import '../../models/word.dart';

// Services
import '../../services/words_service.dart';
import '../../services/audio_service.dart';
import '../../services/speech_service.dart';
import '../../generated/l10n.dart';

// NEW: Import GraphQL + the service we wrote
import '../Services/word_exercise_service.dart';
import '../graphql/graphql_client.dart';

class WordPronunciationScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange;
  final Learner initialLearner;
  final String exerciseId;
  final String levelId;

  const WordPronunciationScreen({
    Key? key,
    this.onLocaleChange,
    required this.initialLearner,
    required this.exerciseId,
    required this.levelId,
  }) : super(key: key);

  @override
  _WordPronunciationScreenState createState() => _WordPronunciationScreenState();
}

class _WordPronunciationScreenState extends State<WordPronunciationScreen> {
  List<String> _wordLetters = [];
  String _currentWord = "";
  String _currentWordId = "";
  String? _currentWordImage;

  int _attemptsLeft = 3;
  String _username = "";
  String _userId = "";

  final AudioService _audioService = AudioService();

  late final String _exerciseId;
  late final String _levelId;

  static const int _maxRecordingSeconds = 30;
  int _timerSeconds = 0;
  Timer? _timer;
  bool _isRecording = false;

  bool _isProcessing = false;
  String _feedbackMessage = "";
  bool? _isCorrect;

  // NEW: We'll store the ExerciseService
  late ExerciseService _exerciseService;

  @override
  void initState() {
    super.initState();
    _exerciseId = widget.exerciseId;
    _levelId = widget.levelId;
    _username = widget.initialLearner.name;
    _userId = widget.initialLearner.id!;
    _loadWord();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_userId.isEmpty) {
        print("❗ No valid user ID available. Cannot start exercise.");
        return;
      }

      final client = await GraphQLService.getClient();
      _exerciseService = ExerciseService(client: client);

      final startResult = await _exerciseService.startExercise(_userId, _exerciseId);
      if (startResult != null) {
        print("Exercise started: $startResult");
      }
    });
  }

  @override
  void dispose() {
    // NEW: Call endExercise
    _exerciseService.endExercise(_userId, _exerciseId).then((endResult) {
      if (endResult != null) {
        print("Exercise ended: $endResult");
        // If you want, store or display timeSpent, etc.
      }
    }).catchError((err) {
      print("Error while ending exercise: $err");
    });

    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  /// Fetch a random word from the database
  Future<void> _loadWord() async {
    setState(() {
      _isProcessing = true;
      _feedbackMessage = "";
      _isCorrect = null;
      _attemptsLeft = 3; // Reset attempts when loading new word
    });

    // Map levelId to backend key for fetching words only
    String backendLevelKey = _getBackendLevelKey(widget.levelId);

    final Word? fetchedWord = await WordsService.fetchRandomWord(backendLevelKey, _exerciseId);

    if (fetchedWord == null) {
      // Handle "no words" scenario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).noWordsAvailable)),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    setState(() {
      _currentWord = fetchedWord.text;
      _currentWordId = fetchedWord.id;
      _wordLetters = fetchedWord.text.split('');
      _currentWordImage = fetchedWord.imageUrl;
      _isProcessing = false;
    });
  }

  /// Start recording + timer
  void _startRecording() async {
    try {
      await _audioService.startRecording();

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _timerSeconds = 0;
        _feedbackMessage = "";
        _isCorrect = null;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() => _timerSeconds++);
        if (_timerSeconds >= _maxRecordingSeconds) {
          _stopRecording();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).recordingTimeout)),
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).recordingStartError('e'))),
      );
    }
  }

  /// Stop recording + timer
  Future<String?> _stopRecording() async {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isRecording = false);
    }
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
      await _stopRecording();
      setState(() {
        _feedbackMessage = S.of(context).ignoredRecording;
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

  /// Process the speech recording with updated attempts logic
  Future<void> _processSpeech(String audioPath) async {
    if (mounted) {
      setState(() {
        _isProcessing = true;
        _feedbackMessage = S.of(context).processingRecording;
      });
    }

    try {
      final result = await SpeechService.processSpeech(
        userId: _userId,
        exerciseId: _exerciseId,
        wordId: _currentWordId,
        levelId: _levelId,
        correctWord: _currentWord,
        audioFilePath: audioPath,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      if (result != null) {
        final bool isCorrect = result['isCorrect'] as bool;
        final String transcript = result['transcript'] as String;
        final String message = result['message'] as String;

        if (mounted) {
          setState(() {
            _feedbackMessage =
                "[S.of(context).transcriptLabel]: $transcript\n$message";
            _isCorrect = isCorrect;
          });
        }

        if (isCorrect) {
          // If correct, wait a moment then load new word automatically
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _loadWord();
        } else {
          // If incorrect, decrease attempts
          if (mounted) {
            setState(() {
              _attemptsLeft = _attemptsLeft > 0 ? _attemptsLeft - 1 : 0;
            });
          }
          // If no attempts left, automatically load new word
          if (_attemptsLeft == 0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).outOfTries)),
              );
            }
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) _loadWord(); // This will reset attempts to 3
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _feedbackMessage = S.of(context).processingError;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _feedbackMessage = S.of(context).recordingError('e');
        });
      }
    }
  }

  /// When "التالي" is pressed, fetch a new word
  void _onNextButtonPressed() {
    _loadWord(); // This will reset attempts to 3
  }

  /// Format seconds as mm:ss
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Helper to map levelId (ObjectId) to backend key for fetching words only
  String _getBackendLevelKey(String levelId) {
    // Map MongoDB ObjectId to backend key
    if (levelId == '681004a0cb31000175a0b1b4') return 'Beginner';
    if (levelId == '681004a0cb31000175a0b1b7') return 'Intermediate';
    if (levelId == '681004a0cb31000175a0b1ba') return 'Advanced';
    return 'Beginner'; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Column(
          children: [
            Text(
              S.of(context).levelLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              S.of(context).greeting(_username),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive dimensions based on screen size
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;
              
              // Define proportional sizes
              final imageHeight = screenHeight * 0.18; // 18% of screen height
              final wordFontSize = screenWidth * 0.1; // 10% of screen width, capped
              final buttonHeight = screenHeight * 0.07; // 7% of screen height
              
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Image with aspect ratio preservation
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06, // 6% of screen width
                            vertical: screenHeight * 0.015, // 1.5% of screen height
                          ),
                          child: SizedBox(
                            height: imageHeight,
                            child: Center(
                              child: _currentWordImage != null
                                  ? AspectRatio(
                                      aspectRatio: 1.0, // Square aspect ratio
                                      child: Image.network(
                                        _currentWordImage!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.broken_image,
                                            size: imageHeight * 0.8,
                                            color: Colors.grey,
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return SizedBox(
                                            height: imageHeight,
                                            child: const Center(child: CircularProgressIndicator()),
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: imageHeight * 0.8,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.012), // 1.2% of screen height

                        // Word text with responsive font size
                        Text(
                          _currentWord,
                          style: TextStyle(
                            fontSize: wordFontSize.clamp(24.0, 48.0), // Clamp between 24-48
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02), // 2% of screen height

                        // Attempts text
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: Column(
                            children: [
                              Text(
                                S.of(context).dontWorry,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0), 
                                  color: Colors.black87
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                S.of(context).attemptsLeft(_attemptsLeft),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0), 
                                  color: Colors.black87
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.012),

                        // Feedback message
                        FeedbackWidget(
                          isProcessing: _isProcessing,
                          isCorrect: _isCorrect,
                          feedbackMessage: _feedbackMessage,
                        ),

                        SizedBox(height: screenHeight * 0.012),

                        // Timer + Progress
                        TimerWidget(
                          isRecording: _isRecording,
                          timerSeconds: _timerSeconds,
                          maxRecordingSeconds: _maxRecordingSeconds,
                          formatTime: _formatTime,
                        ),

                        SizedBox(height: screenHeight * 0.037),

                        // Letters with responsive sizing
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: LettersWidget(letters: _wordLetters),
                        ),

                        SizedBox(height: screenHeight * 0.037),

                        // Control buttons (Wrong, Record, Correct)
                        RecordingControls(
                          isRecording: _isRecording,
                          isProcessing: _isProcessing,
                          onWrongButtonPressed: _onWrongButtonPressed,
                          onRecordButtonPressed: _onRecordButtonPressed,
                          onCorrectButtonPressed: _onCorrectButtonPressed,
                        ),

                        const Spacer(),

                        // Next button with responsive sizing
                        Container(
                          width: double.infinity,
                          height: buttonHeight.clamp(50.0, 70.0), // Clamp button height
                          margin: EdgeInsets.fromLTRB(
                            screenWidth * 0.04, 
                            screenHeight * 0.01, 
                            screenWidth * 0.04, 
                            screenHeight * 0.025
                          ),
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
                            child: Text(
                              S.of(context).nextButton,
                              style: TextStyle(
                                fontSize: (screenWidth * 0.055).clamp(18.0, 26.0), // Responsive font size
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
            },
          ),
        ),
      ),
    );
  }
}