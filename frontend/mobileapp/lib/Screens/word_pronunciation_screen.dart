// word_pronunciation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/widgets/feedback_widget.dart';
import 'package:mobileapp/Screens/widgets/letters_widget.dart';
import 'package:mobileapp/Screens/widgets/recording_controls.dart';
import 'package:mobileapp/Screens/widgets/timer_widget.dart';

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

  const WordPronunciationScreen({
    Key? key,
    this.onLocaleChange,
  }) : super(key: key);

  @override
  _WordPronunciationScreenState createState() => _WordPronunciationScreenState();
}

class _WordPronunciationScreenState extends State<WordPronunciationScreen> {
  List<String> _wordLetters = [];
  String _currentWord = "";
  String _currentWordId = "";
  int _attemptsLeft = 3;

  Learner? _learner;
  String _username = "";
  String _userId = "user123";

  final AudioService _audioService = AudioService();

  final String _exerciseId = "67c66a0e3387a31ba1ee4a72";

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
    _loadWord();

    // Capture any learner info passed in
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Learner) {
        setState(() {
          _learner = args;
          _username = _learner?.name ?? "User";
          _userId = _learner?.id ?? "user123";
        });
      }

      // NEW: Get the GraphQLClient and create an ExerciseService
      final client = await GraphQLService.getClient();
      _exerciseService = ExerciseService(client: client);

      // Now call startExercise
      final startResult = await _exerciseService.startExercise(_userId, _exerciseId);
      if (startResult != null) {
        print("Exercise started: $startResult");
        // If you want, you can store the startTime or message in state.
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
    });

    final Word? fetchedWord = await WordsService.fetchRandomWord("Beginner");

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
            SnackBar(content: Text(S.of(context).recordingTimeout)),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).recordingStartError('$e'))),
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

  /// Process the speech recording
  Future<void> _processSpeech(String audioPath) async {
    setState(() {
      _isProcessing = true;
      _feedbackMessage = S.of(context).processingRecording;
    });

    try {
      final result = await SpeechService.processSpeech(
        userId: _userId,
        exerciseId: _exerciseId,
        wordId: _currentWordId,
        correctWord: _currentWord,
        audioFilePath: audioPath,
      );

      setState(() {
        _isProcessing = false;
      });

      if (result != null) {
        final bool isCorrect = result['isCorrect'] as bool;
        final String transcript = result['transcript'] as String;
        final String message = result['message'] as String;

        setState(() {
          _feedbackMessage =
              "${S.of(context).transcriptLabel}: $transcript\n$message";
          _isCorrect = isCorrect;
        });

        if (!isCorrect) {
          setState(() {
            _attemptsLeft = _attemptsLeft > 0 ? _attemptsLeft - 1 : 0;
          });
          if (_attemptsLeft == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).outOfTries)),
            );
            await Future.delayed(const Duration(seconds: 2));
            _loadWord();
          }
        }
      } else {
        setState(() {
          _feedbackMessage = S.of(context).processingError;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _feedbackMessage = S.of(context).recordingError('$e');
      });
    }
  }

  /// When "التالي" is pressed, fetch a new word
  void _onNextButtonPressed() {
    _loadWord();
    setState(() {
      _attemptsLeft = 3;
    });
  }

  /// Format seconds as mm:ss
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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

              const SizedBox(height: 10),

              // Word text
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
                  Text(
                    S.of(context).dontWorry,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).attemptsLeft(_attemptsLeft),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Feedback message
              FeedbackWidget(
                isProcessing: _isProcessing,
                isCorrect: _isCorrect,
                feedbackMessage: _feedbackMessage,
              ),

              const SizedBox(height: 10),

              // Timer + Progress
              TimerWidget(
                isRecording: _isRecording,
                timerSeconds: _timerSeconds,
                maxRecordingSeconds: _maxRecordingSeconds,
                formatTime: _formatTime,
              ),

              const SizedBox(height: 30),

              // Letters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LettersWidget(letters: _wordLetters),
              ),

              const SizedBox(height: 30),

              // Control buttons (Wrong, Record, Correct)
              RecordingControls(
                isRecording: _isRecording,
                isProcessing: _isProcessing,
                onWrongButtonPressed: _onWrongButtonPressed,
                onRecordButtonPressed: _onRecordButtonPressed,
                onCorrectButtonPressed: _onCorrectButtonPressed,
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
                  child: Text(
                    S.of(context).nextButton,
                    style: const TextStyle(
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
