import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/generated/l10n.dart';

class ObjectDetectionExerciseScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Learner learner;
  final String exerciseId;

  const ObjectDetectionExerciseScreen({
    Key? key,
    required this.onLocaleChange,
    required this.learner,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ObjectDetectionExerciseScreen> createState() => _ObjectDetectionExerciseScreenState();
}

class _ObjectDetectionExerciseScreenState extends State<ObjectDetectionExerciseScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  // TensorFlow Lite
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Exercise variables
  final List<String> _availableObjects = ['spoon', 'cup', 'pen', 'fork', 'plate'];
  String _currentTargetObject = '';
  int _score = 0;
  bool _objectDetected = false;
  String _detectionMessage = '';

  // Detection parameters
  static const double CONFIDENCE_THRESHOLD = 0.5;
  static const int INPUT_SIZE = 224;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _generateNewExercise();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });

        // Start image stream for real-time detection
        _cameraController!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');

      // Load labels - you might need to adjust this based on your model
      _labels = [
        'background', 'person', 'bicycle', 'car', 'motorcycle', 'airplane',
        'bus', 'train', 'truck', 'boat', 'traffic light', 'fire hydrant',
        'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse',
        'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
        'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis',
        'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove',
        'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass',
        'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
        'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza',
        'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed',
        'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote',
        'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
        'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear',
        'hair drier', 'toothbrush'
      ];

      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  void _generateNewExercise() {
    final random = Random();
    setState(() {
      _currentTargetObject = _availableObjects[random.nextInt(_availableObjects.length)];
      _objectDetected = false;
      _detectionMessage = '';
    });
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing || _interpreter == null) return;

    _isProcessing = true;

    try {
      // Convert CameraImage to input tensor
      final inputTensor = _preprocessImage(image);

      // Run inference
      final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
      _interpreter!.run(inputTensor, output);

      // Process results
      _processDetectionResults(output[0]);

    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Float32List _preprocessImage(CameraImage image) {
    // Convert CameraImage to RGB
    final bytes = _convertYUV420ToRGB(image);

    // Create image from bytes
    final img.Image? rgbImage = img.decodeImage(bytes);
    if (rgbImage == null) return Float32List(INPUT_SIZE * INPUT_SIZE * 3);

    // Resize image
    final resized = img.copyResize(rgbImage, width: INPUT_SIZE, height: INPUT_SIZE);

    // Convert to Float32List and normalize
    final input = Float32List(INPUT_SIZE * INPUT_SIZE * 3);
    int pixelIndex = 0;

    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        final pixel = resized.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return input;
  }

  Uint8List _convertYUV420ToRGB(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final Uint8List rgbBytes = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);

        final int yValue = image.planes[0].bytes[yIndex];
        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];

        // YUV to RGB conversion
        int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
        int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round().clamp(0, 255);
        int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

        rgbBytes[yIndex * 3] = r;
        rgbBytes[yIndex * 3 + 1] = g;
        rgbBytes[yIndex * 3 + 2] = b;
      }
    }

    return rgbBytes;
  }

  void _processDetectionResults(List<double> outputs) {
    double maxConfidence = 0.0;
    int maxIndex = 0;

    for (int i = 0; i < outputs.length; i++) {
      if (outputs[i] > maxConfidence) {
        maxConfidence = outputs[i];
        maxIndex = i;
      }
    }

    if (maxConfidence > CONFIDENCE_THRESHOLD) {
      final detectedLabel = _labels[maxIndex].toLowerCase();

      // Check if detected object matches target
      if (detectedLabel == _currentTargetObject && !_objectDetected) {
        setState(() {
          _objectDetected = true;
          _score += 10;
          _detectionMessage = S.of(context).objectDetected;
        });

        // Auto-advance to next exercise after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          _generateNewExercise();
        });
      }
    }
  }

  String _getObjectTranslation(String objectKey) {
    final localizations = S.of(context);
    switch (objectKey) {
      case 'spoon':
        return localizations.spoon;
      case 'cup':
        return localizations.cup;
      case 'pen':
        return localizations.pen;
      case 'fork':
        return localizations.fork;
      case 'plate':
        return localizations.plate;
      default:
        return objectKey;
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.objectDetectionExercise),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Score and Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  localizations.score(_score),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Text(
                    '${localizations.bringObject(_getObjectTranslation(_currentTargetObject))}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.objectDetectionHint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isCameraInitialized && _cameraController != null
                    ? Stack(
                        children: [
                          CameraPreview(_cameraController!),
                          if (_objectDetected)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.green.withOpacity(0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            ),
          ),

          // Status Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _objectDetected ? Colors.green.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _objectDetected ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                _detectionMessage.isEmpty
                    ? localizations.objectNotFound
                    : _detectionMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _objectDetected ? Colors.green.shade700 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Next Exercise Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateNewExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations.nextExercise,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}