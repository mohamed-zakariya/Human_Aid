import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'dart:async';

class HandDetectionGameWidget extends StatefulWidget {
  const HandDetectionGameWidget({Key? key}) : super(key: key);

  @override
  State<HandDetectionGameWidget> createState() => _HandDetectionGameWidgetState();
}

class _HandDetectionGameWidgetState extends State<HandDetectionGameWidget>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  late AnimationController _pulseAnimationController;
  late AnimationController _successAnimationController;
  late AnimationController _correctAnswerAnimationController;

  // Game state
  HandSide _targetHand = HandSide.left;
  int _score = 0;
  int _level = 1;
  bool _isGameActive = false;
  bool _waitingForAnswer = false;
  bool _processingAnswer = false;
  Timer? _gameTimer;
  Timer? _detectionTimer;
  Timer? _questionTimer;

  // Hand tracking state
  String _detectedHand = "None";
  bool _handDetected = false;
  bool _isCorrectHand = false;
  double _handConfidence = 0.0;

  // Question timing
  Duration _questionWaitTime = const Duration(seconds: 4);
  Duration _correctAnswerDisplayTime = const Duration(seconds: 2);
  int _correctAnswersInRow = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _correctAnswerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Try to find front camera first
        CameraDescription? frontCamera;
        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.front) {
            frontCamera = camera;
            break;
          }
        }

        _cameraController = CameraController(
          frontCamera ?? cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startHandDetection() {
    // Start continuous hand detection
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!_isGameActive || _processingAnswer) return;
      _processHandDetection();
    });
  }

  void _stopHandDetection() {
    _detectionTimer?.cancel();
  }

  void _processHandDetection() {
    // Enhanced hand detection simulation with better left/right accuracy
    final random = math.Random();

    setState(() {
      // Simulate hand detection with more realistic patterns
      _handDetected = random.nextDouble() > 0.25; // 75% chance of detection

      if (_handDetected) {
        // Simulate hand confidence (higher for stable detection)
        _handConfidence = 0.75 + (random.nextDouble() * 0.25);

        // Better left/right hand detection logic
        double detectionAccuracy = random.nextDouble();

        if (detectionAccuracy > 0.15) { // 85% accurate detection
          // Simulate realistic hand detection based on camera position
          if (_waitingForAnswer) {
            // When we're waiting for an answer, bias toward correct detection sometimes
            if (random.nextDouble() > 0.7) { // 30% chance of showing correct hand
              _detectedHand = _targetHand.name.substring(0, 1).toUpperCase() +
                  _targetHand.name.substring(1);
            } else {
              // Random detection
              _detectedHand = random.nextBool() ? "Left" : "Right";
            }
          } else {
            // Random detection when not in question mode
            _detectedHand = random.nextBool() ? "Left" : "Right";
          }
        } else {
          _detectedHand = "Uncertain";
        }

        // Check if detected hand matches target (case-insensitive comparison)
        String targetHandName = _targetHand.name.substring(0, 1).toUpperCase() +
            _targetHand.name.substring(1);
        _isCorrectHand = (_detectedHand == targetHandName) &&
            (_detectedHand != "Uncertain") &&
            _handConfidence > 0.8;

        // If correct hand is detected with high confidence and we're waiting for answer
        if (_isCorrectHand && _waitingForAnswer && !_processingAnswer) {
          // Add small delay to ensure stable detection
          Timer(const Duration(milliseconds: 500), () {
            if (_isCorrectHand && _waitingForAnswer && !_processingAnswer) {
              _onCorrectAnswer();
            }
          });
        }
      } else {
        _detectedHand = "None";
        _handConfidence = 0.0;
        _isCorrectHand = false;
      }
    });
  }

  void _onCorrectAnswer() {
    if (_processingAnswer) return;

    // Double-check that we still have the correct hand detected
    String targetHandName = _targetHand.name.substring(0, 1).toUpperCase() +
        _targetHand.name.substring(1);

    if (_detectedHand != targetHandName || _handConfidence < 0.8) {
      return; // Don't process if hand detection changed
    }

    setState(() {
      _processingAnswer = true;
      _waitingForAnswer = false;
      _score += 10 * _level;
      _correctAnswersInRow++;
    });

    _questionTimer?.cancel();

    // Play success animation
    _successAnimationController.forward().then((_) {
      _successAnimationController.reset();
    });

    _correctAnswerAnimationController.forward();

    // Show correct answer feedback for 2 seconds
    Timer(_correctAnswerDisplayTime, () {
      _correctAnswerAnimationController.reverse().then((_) {
        if (_isGameActive) {
          _generateNextQuestion();
        }
      });
    });
  }

  void _onTimeUp() {
    if (!_waitingForAnswer || _processingAnswer) return;

    setState(() {
      _waitingForAnswer = false;
      _correctAnswersInRow = 0;
    });

    // Brief pause before next question
    Timer(const Duration(milliseconds: 800), () {
      if (_isGameActive) {
        _generateNextQuestion();
      }
    });
  }

  void _generateNextQuestion() {
    if (!_isGameActive) return;

    setState(() {
      _processingAnswer = false;
      _waitingForAnswer = true;
      _isCorrectHand = false;

      // Generate new target hand
      _targetHand = math.Random().nextBool() ? HandSide.left : HandSide.right;
    });

    // Increase difficulty based on performance
    if (_correctAnswersInRow > 0 && _correctAnswersInRow % 5 == 0) {
      setState(() {
        _level++;
        _questionWaitTime = Duration(
            milliseconds: math.max(2000, _questionWaitTime.inMilliseconds - 300)
        );
      });
    }

    // Set timer for question timeout
    _questionTimer = Timer(_questionWaitTime, _onTimeUp);
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _score = 0;
      _level = 1;
      _correctAnswersInRow = 0;
      _questionWaitTime = const Duration(seconds: 4);
      _waitingForAnswer = false;
      _processingAnswer = false;
    });

    _startHandDetection();

    // Start first question after brief delay
    Timer(const Duration(milliseconds: 1000), () {
      if (_isGameActive) {
        _generateNextQuestion();
      }
    });
  }

  void _stopGame() {
    setState(() {
      _isGameActive = false;
      _waitingForAnswer = false;
      _processingAnswer = false;
    });

    _stopHandDetection();
    _questionTimer?.cancel();
    _correctAnswerAnimationController.reset();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseAnimationController.dispose();
    _successAnimationController.dispose();
    _correctAnswerAnimationController.dispose();
    _detectionTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hand Detection Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level $_level',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score and Status Display
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Streak',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$_correctAnswersInRow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _handDetected ? Icons.visibility : Icons.visibility_off,
                          color: _handDetected ? (_isCorrectHand ? Colors.green : Colors.orange) : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hand: $_detectedHand',
                          style: TextStyle(
                            color: _isCorrectHand ? Colors.green : Colors.white,
                            fontSize: 14,
                            fontWeight: _isCorrectHand ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (_handDetected)
                      Text(
                        '${(_handConfidence * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Camera Preview and Question Display
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Stack(
                children: [
                  // Camera Preview
                  if (_isCameraInitialized && _cameraController != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CameraPreview(_cameraController!),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.black54,
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Initializing Camera...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Question Display
                  if (_waitingForAnswer)
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseAnimationController.value * 0.1),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Show Your',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_targetHand.name.toUpperCase()} HAND',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Icon(
                                    _targetHand == HandSide.left
                                        ? Icons.back_hand
                                        : Icons.front_hand,
                                    size: 48,
                                    color: const Color(0xFF4F46E5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Correct Answer Animation
                  if (_processingAnswer)
                    Center(
                      child: AnimatedBuilder(
                        animation: _correctAnswerAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _correctAnswerAnimationController.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.4),
                                    spreadRadius: 5,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'CORRECT!',
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Great job!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Detection Status Overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isCorrectHand ? Icons.check : Icons.close,
                                color: _isCorrectHand ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _waitingForAnswer ? 'Waiting...' : 'Ready',
                                style: TextStyle(
                                  color: _waitingForAnswer ? Colors.yellow : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${_targetHand.name.toUpperCase()}',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Text(
                            'Detected: $_detectedHand',
                            style: TextStyle(
                                color: _isCorrectHand ? Colors.green : Colors.white,
                                fontSize: 11
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGameActive ? _stopGame : _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isGameActive ? Colors.red : Colors.white,
                      foregroundColor: _isGameActive ? Colors.white : const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _isGameActive ? 'Stop Game' : 'Start Game',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _showInstructionsDialog,
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Objective', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Show the correct hand when prompted'),
            SizedBox(height: 12),
            Text('📋 Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Position yourself in front of the camera'),
            Text('2. Wait for the hand prompt to appear'),
            Text('3. Show your LEFT or RIGHT hand clearly'),
            Text('4. Hold it steady until you get points!'),
            SizedBox(height: 12),
            Text('⚡ Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Good lighting helps detection'),
            Text('• Keep your hand in center of screen'),
            Text('• Build streaks for higher levels!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

enum HandSide { left, right }