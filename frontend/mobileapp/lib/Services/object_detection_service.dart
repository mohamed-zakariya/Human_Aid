import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ObjectDetectionService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  // These should match your actual model's requirements
  static const int inputSize = 224;
  static const double threshold = 0.5;

  // Add debugging flag
  static const bool _debug = true;

  Future<void> initialize() async {
    try {
      if (_debug) print('🔄 Starting model initialization...');

      // First, verify the model file exists
      await _verifyModelExists();

      // Load the model with specific options for better compatibility
      final options = InterpreterOptions();
      if (Platform.isAndroid) {
        // For Android, try to use GPU delegate if available
        try {
          options.addDelegate(GpuDelegate());
          if (_debug) print('✅ GPU delegate added for Android');
        } catch (e) {
          if (_debug) print('⚠️ GPU delegate not available, using CPU: $e');
        }
      }

      _interpreter = await Interpreter.fromAsset('model.tflite', options: options);
      if (_debug) print('✅ Model loaded successfully');

      // Validate model input/output tensors
      await _validateModelTensors();

      // Load labels
      await _loadLabelsWithFallback();

      _isInitialized = true;
      if (_debug) print('🎉 Object detection model initialized successfully');

    } catch (e, stackTrace) {
      if (_debug) {
        print('❌ Error initializing object detection: $e');
        print('Stack trace: $stackTrace');
      }
      _isInitialized = false;

      // Try fallback initialization without GPU delegate
      await _fallbackInitialization();
    }
  }

  Future<void> _verifyModelExists() async {
    try {
      final modelData = await rootBundle.load('assets/model.tflite');
      if (_debug) print('✅ Model file found, size: ${modelData.lengthInBytes} bytes');

      if (modelData.lengthInBytes == 0) {
        throw Exception('Model file is empty');
      }
    } catch (e) {
      if (_debug) print('❌ Model file verification failed: $e');
      throw Exception('Model file not found in assets/model.tflite. Please check your pubspec.yaml');
    }
  }

  Future<void> _validateModelTensors() async {
    if (_interpreter == null) return;

    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      if (_debug) {
        print('📊 Model input shape: ${inputTensor.shape}');
        print('📊 Model input type: ${inputTensor.type}');
        print('📊 Model output shape: ${outputTensor.shape}');
        print('📊 Model output type: ${outputTensor.type}');
      }

      // Validate expected input shape for image classification
      final inputShape = inputTensor.shape;
      if (inputShape.length != 4) {
        throw Exception('Expected 4D input tensor (batch, height, width, channels), got: $inputShape');
      }

      final expectedChannels = inputShape[3];
      if (expectedChannels != 3) {
        if (_debug) print('⚠️ Warning: Model expects $expectedChannels channels, we provide 3 (RGB)');
      }

    } catch (e) {
      if (_debug) print('❌ Model tensor validation failed: $e');
      rethrow;
    }
  }

  Future<void> _loadLabelsWithFallback() async {
    try {
      _labels = await _loadLabels('labels.txt');
      if (_debug) print('✅ Labels loaded: ${_labels!.length} labels');
    } catch (e) {
      if (_debug) print('⚠️ No labels file found, using default labels: $e');
      _labels = _getDefaultLabels();
      if (_debug) print('✅ Using ${_labels!.length} default labels');
    }
  }

  Future<void> _fallbackInitialization() async {
    try {
      if (_debug) print('🔄 Attempting fallback initialization without GPU...');

      // Try with basic options
      _interpreter = await Interpreter.fromAsset('model.tflite');
      await _validateModelTensors();
      await _loadLabelsWithFallback();

      _isInitialized = true;
      if (_debug) print('✅ Fallback initialization successful');
    } catch (fallbackError) {
      if (_debug) print('❌ Fallback initialization also failed: $fallbackError');
      _isInitialized = false;
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    try {
      final labelsData = await rootBundle.loadString('assets/$path');
      final labels = labelsData.split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      if (labels.isEmpty) {
        throw Exception('Labels file is empty');
      }

      return labels;
    } catch (e) {
      throw Exception('Could not load labels from assets/$path: $e');
    }
  }

  List<String> _getDefaultLabels() {
    // COCO dataset labels (commonly used for object detection)
    return [
      'background',
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic light',
      'fire hydrant',
      'stop sign',
      'parking meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports ball',
      'kite',
      'baseball bat',
      'baseball glove',
      'skateboard',
      'surfboard',
      'tennis racket',
      'bottle',
      'wine glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted plant',
      'bed',
      'dining table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy bear',
      'hair drier',
      'toothbrush',
      'plate',
      'pen',
      'pencil',
      'mug',
      'glass',
      'dish',
      'utensil',
      'notebook'
    ];
  }

  Future<Map<String, double>> detectObjects(CameraImage cameraImage) async {
    if (!_isInitialized || _interpreter == null) {
      if (_debug) print('⚠️ Model not initialized - skipping detection');
      return {};
    }

    try {
      // Convert CameraImage to input format with better error handling
      final input = await _preprocessImageSafe(cameraImage);
      if (input == null) {
        if (_debug) print('❌ Failed to preprocess image');
        return {};
      }

      // Get model tensors
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      // Prepare output tensor with correct shape
      final outputShape = outputTensor.shape;
      var output = _createOutputTensor(outputShape);

      // Run inference with timeout
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();

      if (_debug) print('⏱️ Inference time: ${stopwatch.elapsedMilliseconds}ms');

      // Process results
      return _processOutput(output);

    } catch (e, stackTrace) {
      if (_debug) {
        print('❌ Error during detection: $e');
        print('Stack trace: $stackTrace');
      }
      return {};
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImageSafe(CameraImage cameraImage) async {
    try {
      // Convert CameraImage to RGB bytes with better error handling
      final bytes = await _convertCameraImageToBytesSafe(cameraImage);
      if (bytes.isEmpty) {
        if (_debug) print('❌ Failed to convert camera image to bytes');
        return null;
      }

      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        if (_debug) print('❌ Failed to decode image');
        return null;
      }

      // Resize to model input size
      final resized = img.copyResize(image, width: inputSize, height: inputSize);

      // Convert to model input format (normalized float32)
      final input = List.generate(1, (batch) =>
        List.generate(inputSize, (y) =>
          List.generate(inputSize, (x) =>
            List.generate(3, (c) {
              final pixel = resized.getPixel(x, y);
              double value;
              switch (c) {
                case 0: value = pixel.r.toDouble(); break;
                case 1: value = pixel.g.toDouble(); break;
                case 2: value = pixel.b.toDouble(); break;
                default: value = 0.0;
              }
              // Normalize to [0, 1] (adjust based on your model's requirements)
              return value / 255.0;
            })
          )
        )
      );

      return input;

    } catch (e, stackTrace) {
      if (_debug) {
        print('❌ Error preprocessing image: $e');
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  Future<Uint8List> _convertCameraImageToBytesSafe(CameraImage image) async {
    try {
      if (_debug) print('🔄 Converting camera image format: ${image.format.group}');

      switch (image.format.group) {
        case ImageFormatGroup.yuv420:
          return _convertYUV420ToRGBSafe(image);
        case ImageFormatGroup.bgra8888:
          return _convertBGRA8888ToRGBSafe(image);
        case ImageFormatGroup.nv21:
          return _convertNV21ToRGBSafe(image);
        default:
          if (_debug) print('❌ Unsupported image format: ${image.format.group}');
          return Uint8List(0);
      }
    } catch (e) {
      if (_debug) print('❌ Error converting camera image: $e');
      return Uint8List(0);
    }
  }

  Uint8List _convertYUV420ToRGBSafe(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final Uint8List rgb = Uint8List(width * height * 3);

      // Validate planes
      if (image.planes.length < 3) {
        throw Exception('YUV420 image must have 3 planes');
      }

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final int uvRowStride = uPlane.bytesPerRow;
      final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

      for (int y = 0; y < height; y++) {
        int yRowOffset = y * yPlane.bytesPerRow;
        int uvRowOffset = (y ~/ 2) * uvRowStride;

        for (int x = 0; x < width; x++) {
          final int yIndex = yRowOffset + x;
          final int uvIndex = uvRowOffset + (x ~/ 2) * uvPixelStride;

          // Bounds checking
          if (yIndex >= yPlane.bytes.length ||
              uvIndex >= uPlane.bytes.length ||
              uvIndex >= vPlane.bytes.length) {
            continue;
          }

          final int yValue = yPlane.bytes[yIndex];
          final int uValue = uPlane.bytes[uvIndex];
          final int vValue = vPlane.bytes[uvIndex];

          // YUV to RGB conversion
          int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
          int g = (yValue - 0.698001 * (vValue - 128) - 0.337633 * (uValue - 128)).round().clamp(0, 255);
          int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

          final int rgbIndex = (y * width + x) * 3;
          if (rgbIndex + 2 < rgb.length) {
            rgb[rgbIndex] = r;
            rgb[rgbIndex + 1] = g;
            rgb[rgbIndex + 2] = b;
          }
        }
      }

      return rgb;
    } catch (e) {
      if (_debug) print('❌ Error in YUV420 conversion: $e');
      return Uint8List(0);
    }
  }

  Uint8List _convertBGRA8888ToRGBSafe(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final Uint8List rgb = Uint8List(width * height * 3);
      final Uint8List bgra = image.planes[0].bytes;

      for (int i = 0; i < width * height; i++) {
        final int bgraIndex = i * 4;
        final int rgbIndex = i * 3;

        if (bgraIndex + 3 < bgra.length && rgbIndex + 2 < rgb.length) {
          rgb[rgbIndex] = bgra[bgraIndex + 2];     // R
          rgb[rgbIndex + 1] = bgra[bgraIndex + 1]; // G
          rgb[rgbIndex + 2] = bgra[bgraIndex];     // B
        }
      }

      return rgb;
    } catch (e) {
      if (_debug) print('❌ Error in BGRA8888 conversion: $e');
      return Uint8List(0);
    }
  }

  Uint8List _convertNV21ToRGBSafe(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final Uint8List rgb = Uint8List(width * height * 3);

      final yPlane = image.planes[0];
      final uvPlane = image.planes[1];

      for (int y = 0; y < height; y++) {
        int yRowOffset = y * yPlane.bytesPerRow;
        int uvRowOffset = (y ~/ 2) * uvPlane.bytesPerRow;

        for (int x = 0; x < width; x++) {
          final int yIndex = yRowOffset + x;
          final int uvIndex = uvRowOffset + (x ~/ 2) * 2;

          if (yIndex >= yPlane.bytes.length || uvIndex + 1 >= uvPlane.bytes.length) {
            continue;
          }

          final int yValue = yPlane.bytes[yIndex];
          final int vValue = uvPlane.bytes[uvIndex];
          final int uValue = uvPlane.bytes[uvIndex + 1];

          // YUV to RGB conversion
          int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
          int g = (yValue - 0.698001 * (vValue - 128) - 0.337633 * (uValue - 128)).round().clamp(0, 255);
          int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

          final int rgbIndex = (y * width + x) * 3;
          if (rgbIndex + 2 < rgb.length) {
            rgb[rgbIndex] = r;
            rgb[rgbIndex + 1] = g;
            rgb[rgbIndex + 2] = b;
          }
        }
      }

      return rgb;
    } catch (e) {
      if (_debug) print('❌ Error in NV21 conversion: $e');
      return Uint8List(0);
    }
  }

  dynamic _createOutputTensor(List<int> outputShape) {
    if (outputShape.length == 2) {
      return List.generate(outputShape[0], (i) => List.filled(outputShape[1], 0.0));
    } else if (outputShape.length == 1) {
      return [List.filled(outputShape[0], 0.0)];
    } else {
      // For multi-dimensional outputs, create nested lists
      final totalSize = outputShape.reduce((a, b) => a * b);
      return [List.filled(totalSize, 0.0)];
    }
  }

  Map<String, double> _processOutput(dynamic output) {
    Map<String, double> results = {};

    try {
      List<double> scores;

      // Extract scores based on output format
      if (output is List<List<double>>) {
        scores = output[0];
      } else if (output is List<double>) {
        scores = output;
      } else {
        if (_debug) print('❌ Unexpected output format: ${output.runtimeType}');
        return results;
      }

      // Find objects above threshold
      for (int i = 0; i < scores.length && i < (_labels?.length ?? 0); i++) {
        if (scores[i] > threshold) {
          String label = _labels?[i] ?? 'object_$i';
          results[label.toLowerCase()] = scores[i];
        }
      }

      if (results.isNotEmpty && _debug) {
        print('🎯 Detection results: $results');
      }

    } catch (e) {
      if (_debug) print('❌ Error processing output: $e');
    }

    return results;
  }

  bool get isInitialized => _isInitialized;

  void dispose() {
    try {
      _interpreter?.close();
      _interpreter = null;
      _isInitialized = false;
      if (_debug) print('🧹 ObjectDetectionService disposed');
    } catch (e) {
      if (_debug) print('❌ Error disposing ObjectDetectionService: $e');
    }
  }
}