import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'dart:async';

class ArrowDetectionGameWidget extends StatefulWidget {
  const ArrowDetectionGameWidget({Key? key}) : super(key: key);

  @override
  State<ArrowDetectionGameWidget> createState() => _ArrowDetectionGameWidgetState();
}

class _ArrowDetectionGameWidgetState extends State<ArrowDetectionGameWidget>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  late AnimationController _arrowAnimationController;
  late AnimationController _pulseAnimationController;

  // Game state
  ArrowDirection _currentArrowDirection = ArrowDirection.up;
  int _score = 0;
  int _level = 1;
  bool _isGameActive = false;
  Timer? _gameTimer;
  Duration _arrowDisplayTime = const Duration(seconds: 3);

  // Hand tracking state
  String _detectedGesture = "None";
  bool _handDetected = false;
  String _handedness = "Unknown";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });

          // Start hand detection processing
          _startHandDetection();
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startHandDetection() {
    // Simulate hand detection with MediaPipe
    // In real implementation, you would process camera frames here
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isGameActive) return;

      // Simulate hand tracking results
      _simulateHandTracking();
    });
  }

  void _simulateHandTracking() {
    // This is a simulation - replace with actual MediaPipe integration
    setState(() {
      _handDetected = math.Random().nextBool();
      if (_handDetected) {
        _handedness = math.Random().nextBool() ? "Left" : "Right";
        _detectedGesture = _getRandomGesture();

        // Check if gesture matches current arrow
        _checkGestureMatch();
      }
    });
  }

  String _getRandomGesture() {
    final gestures = ['up', 'down', 'left', 'right'];
    return gestures[math.Random().nextInt(gestures.length)];
  }

  void _checkGestureMatch() {
    final expectedGesture = _currentArrowDirection.name;
    if (_detectedGesture.toLowerCase() == expectedGesture) {
      _onCorrectGesture();
    }
  }

  void _onCorrectGesture() {
    setState(() {
      _score += 10 * _level;
    });

    _arrowAnimationController.forward().then((_) {
      _arrowAnimationController.reset();
      _generateNewArrow();
    });
  }

  void _generateNewArrow() {
    setState(() {
      _currentArrowDirection = ArrowDirection.values[
      math.Random().nextInt(ArrowDirection.values.length)
      ];
    });

    // Increase difficulty over time
    if (_score > 0 && _score % 100 == 0) {
      setState(() {
        _level++;
        _arrowDisplayTime = Duration(
            milliseconds: math.max(1000, _arrowDisplayTime.inMilliseconds - 200)
        );
      });
    }
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _score = 0;
      _level = 1;
      _arrowDisplayTime = const Duration(seconds: 3);
    });

    _generateNewArrow();
  }

  void _stopGame() {
    setState(() {
      _isGameActive = false;
    });
    _gameTimer?.cancel();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _arrowAnimationController.dispose();
    _pulseAnimationController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Arrow Detection Game',
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
          // Score Display
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Hand Detected',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Row(
                      children: [
                        Icon(
                          _handDetected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _handDetected ? Colors.green : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _handedness,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Camera Preview and Arrow Display
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
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),

                  // Arrow Display Overlay
                  if (_isGameActive)
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _arrowAnimationController,
                          _pulseAnimationController
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseAnimationController.value * 0.1),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: _getArrowRotation(_currentArrowDirection),
                                child: const Icon(
                                  Icons.arrow_upward,
                                  size: 60,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Hand Tracking Info Overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gesture: $_detectedGesture',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            'Target: ${_currentArrowDirection.name.toUpperCase()}',
                            style: const TextStyle(color: Colors.yellow, fontSize: 12),
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
                      foregroundColor: _isGameActive ? Colors.white : const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    onPressed: () {
                      // Show instructions dialog
                      _showInstructionsDialog();
                    },
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

  double _getArrowRotation(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.up:
        return 0;
      case ArrowDirection.right:
        return math.pi / 2;
      case ArrowDirection.down:
        return math.pi;
      case ArrowDirection.left:
        return -math.pi / 2;
    }
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
            Text('1. Position your hand in front of the camera'),
            SizedBox(height: 8),
            Text('2. Point your finger in the direction of the arrow'),
            SizedBox(height: 8),
            Text('3. Score points for correct gestures'),
            SizedBox(height: 8),
            Text('4. Level up as you progress!'),
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

enum ArrowDirection { up, down, left, right }