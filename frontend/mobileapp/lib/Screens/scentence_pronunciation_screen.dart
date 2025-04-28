import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/learner.dart';
import '../../models/scentence.dart';
import '../../services/audio_service.dart';
import '../../services/sentence_exercise_service.dart';
import '../../services/tts_service.dart';

class SentencePronunciationScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange;

  const SentencePronunciationScreen({super.key, this.onLocaleChange});

  @override
  State<SentencePronunciationScreen> createState() =>
      _SentencePronunciationScreenState();
}

class _SentencePronunciationScreenState
    extends State<SentencePronunciationScreen> with SingleTickerProviderStateMixin {
  // learner / session meta
  late Learner _learner;
  late String _userId;
  final String _level = 'Beginner'; // or read from learner
  String _exerciseId = '';

  // runtime state
  final TTSService _tts = TTSService();
  final AudioService _audio = AudioService();
  List<Sentence> _sentences = [];
  int _current = 0;
  bool _loading = true;
  bool _recording = false;
  String? _feedback;
  bool _isCorrect = false;
  int _score = 0;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      )
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _readArgsAndStart());
  }

  void _readArgsAndStart() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Learner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learner data missing')),
      );
      Navigator.pop(context);
      return;
    }
    _learner = args;
    _userId = _learner.id!;
    await _startSession();
    _animationController.forward();
  }

  Future<void> _startSession() async {
    try {
      await _tts.initialize();
      await SentenceExerciseService.startExercise(_userId, '');
      _sentences = await SentenceExerciseService.fetchSentences(_level);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    if (_exerciseId.isNotEmpty) {
      SentenceExerciseService.endExercise(_userId, _exerciseId);
    }
    _tts.dispose();
    _audio.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /* ───────── helpers ───────── */

  Future<void> _playSentence() async {
    if (_sentences.isEmpty) return;
    await _tts.speak(_sentences[_current].text);
  }

  Future<void> _toggleRecording() async {
    if (_sentences.isEmpty) return;

    if (_recording) {
      final path = await _audio.stopRecording();
      setState(() => _recording = false);

      if (path != null) {
        _showProcessingIndicator();
        
        final result = await SentenceExerciseService.submitSentence(
          userId: _userId,
          exerciseId: _exerciseId,
          sentence: _sentences[_current],
          recordingPath: path,
        );

        if (mounted) {
          setState(() {
            _feedback = result['message'];
            _isCorrect = result['isCorrect'] ?? false;
            _score = result['updatedData']?['score'] ?? _score;
          });
          
          if (_isCorrect && _current < _sentences.length - 1) {
            _showSuccessAnimation().then((_) {
              if (mounted) {
                setState(() {
                  _current++;
                  _feedback = null;
                  _isCorrect = false;
                });
              }
            });
          }
        }
      }
    } else {
      await _audio.startRecording();
      setState(() {
        _feedback = null;
        _recording = true;
        _isCorrect = false;
      });
    }
  }
  
  void _showProcessingIndicator() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing your pronunciation...'),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => Navigator.of(context).pop());
  }
  
  Future<void> _showSuccessAnimation() async {
    return Future.delayed(const Duration(milliseconds: 1500));
  }

  void _navigateToNext() {
    if (_current < _sentences.length - 1) {
      setState(() {
        _current++;
        _feedback = null;
      });
    }
  }

  /* ───────── UI ───────── */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sentence Pronunciation'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No sentences available',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final sentenceText = _sentences[_current].text;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: colorScheme.primaryContainer,
              label: Text(
                'Score: $_score',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              avatar: Icon(
                Icons.star,
                color: colorScheme.onPrimaryContainer,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _animation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: (_current + 1) / _sentences.length,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimaryContainer,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sentence ${_current + 1}/${_sentences.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _level,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sentence Card
                  Expanded(
                    child: Hero(
                      tag: 'sentence_card',
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sentenceText,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.volume_up),
                                label: const Text('Listen'),
                                onPressed: _playSentence,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor: colorScheme.onPrimaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Feedback Section
                  if (_feedback != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCorrect ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isCorrect ? Icons.check_circle : Icons.info,
                            color: _isCorrect ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _feedback!,
                              style: TextStyle(
                                color: _isCorrect ? Colors.green[800] : Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_isCorrect)
                            TextButton(
                              onPressed: _navigateToNext,
                              child: const Text('Next'),
                            ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Record Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _recording
                          ? Colors.red.withOpacity(0.7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: _toggleRecording,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _recording ? Icons.stop : Icons.mic,
                                color: _recording
                                    ? Colors.white
                                    : colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _recording ? 'Stop Recording' : 'Record Your Voice',
                                style: TextStyle(
                                  color: _recording
                                      ? Colors.white
                                      : colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}