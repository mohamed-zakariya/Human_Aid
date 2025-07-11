import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../Services/hand_api_service.dart';
import '../generated/l10n.dart';

class Level1CameraScreen extends StatefulWidget {
  @override
  _Level1CameraScreenState createState() => _Level1CameraScreenState();
}

class _Level1CameraScreenState extends State<Level1CameraScreen> {
  final List<String> targetWords = ["ملعقة", "شوكة", "كتاب", "قلم", "كوب", "طبق"];
  List<String> completedWords = [];
  int score = 0;
  String? randomTarget;
  String? predictedObject;
  bool isLoading = false;
  bool isDetecting = false;
  bool showNextButton = false;
  bool allCompleted = false;

  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  // Detection timing
  DateTime? _lastDetectionTime;
  static const Duration _detectionCooldown = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    pickRandomWord();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void pickRandomWord() {
    final remaining = targetWords.where((w) => !completedWords.contains(w)).toList();
    if (remaining.isEmpty) {
      setState(() {
        allCompleted = true;
        randomTarget = null;
      });
      return;
    }
    randomTarget = (remaining..shuffle()).first;
    setState(() {
      showNextButton = false;
      predictedObject = null;
    });
  }

  void handleCorrectAnswer() {
    if (randomTarget != null && !completedWords.contains(randomTarget)) {
      setState(() {
        completedWords.add(randomTarget!);
        score++;
        showNextButton = true;
      });
      _stopContinuousDetection();
    }
  }

  void handleNext() {
    pickRandomWord();
    if (!allCompleted) {
      _startContinuousDetection();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Use back camera
          ResolutionPreset.medium, // Increased resolution for better quality
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        setState(() {
          _isCameraInitialized = true;
        });
        
        // Start continuous detection
        _startContinuousDetection();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startContinuousDetection() {
    if (!_isCameraInitialized || isDetecting) return;
    
    // Start image stream for real-time detection
    _cameraController!.startImageStream((CameraImage image) {
      _processImage(image);
    });
  }

  void _stopContinuousDetection() {
    if (_cameraController != null && _isCameraInitialized) {
      _cameraController!.stopImageStream();
    }
  }

  Future<void> _processImage(CameraImage image) async {
    // Throttle detection to avoid overwhelming the API
    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!) < _detectionCooldown) {
      return;
    }
    
    if (isDetecting) return;
    
    setState(() {
      isDetecting = true;
    });
    
    _lastDetectionTime = now;
    
    try {
      // Convert CameraImage to File
      final File imageFile = await _convertCameraImageToFile(image);
      
      // Send to API
      final apiService = HandApiService();
      final responseText = await apiService.uploadImage(imageFile);
      
      if (mounted) {
        _processApiResponse(responseText);
      }
      
      // Clean up temporary file
      await imageFile.delete();
      
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          isDetecting = false;
        });
      }
    }
  }

  Future<File> _convertCameraImageToFile(CameraImage image) async {
    try {
      late img.Image convertedImage;
      
      if (image.format.group == ImageFormatGroup.yuv420) {
        // Convert YUV420 to Image
        convertedImage = _convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // Convert BGRA8888 to Image
        convertedImage = _convertBGRA8888ToImage(image);
      } else {
        throw UnsupportedError('Unsupported image format: ${image.format.group}');
      }
      
      // Resize image to reduce API call size (optional)
      final resizedImage = img.copyResize(convertedImage, width: 640);
      
      // Convert to JPEG bytes
      final jpegBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(filePath);
      
      await file.writeAsBytes(jpegBytes);
      return file;
      
    } catch (e) {
      print('Error converting camera image: $e');
      rethrow;
    }
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    
    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    
    final convertedImage = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * yRowStride + x;
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        
        final int yValue = image.planes[0].bytes[yIndex];
        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];
        
        // YUV to RGB conversion
        final int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
        final int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128)).round().clamp(0, 255);
        final int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);
        
        convertedImage.setPixelRgb(x, y, r, g, b);
      }
    }
    
    return convertedImage;
  }

  img.Image _convertBGRA8888ToImage(CameraImage image) {
    final convertedImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      format: img.Format.uint8,
      numChannels: 4,
    );
    
    return convertedImage;
  }

  void _processApiResponse(String? responseText) {
    try {
      if (responseText != null) {
        final decoded = json.decode(responseText);
        final rawObject = decoded['object']?.toString().trim();
        
        // Check if it's "no object found" - don't flip this
        String processedObject;
        if (rawObject == "لا يوجد كائن") {
          processedObject = rawObject!; // Keep as is
        } else {
          // For other detected objects, apply reversal and normalization
          final reversedObject = reverseArabic(rawObject ?? '');
          processedObject = fixArabicPresentationForms(reversedObject);
        }

        print('🔍 predicted: ${processedObject.runes.toList()}');
        print('🎯 target   : ${randomTarget!.runes.toList()}');

        setState(() {
          predictedObject = processedObject;
        });
        
        if (randomTarget != null && normalizeAndCompare(processedObject, randomTarget!)) {
          handleCorrectAnswer();
        }
      }
    } catch (e) {
      setState(() {
        predictedObject = S.of(context).errorReadingResult;
      });
    }
  }

  // Keep your existing Arabic text processing methods
  String reverseArabic(String input) {
    return input.split('').reversed.join();
  }

  String normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('\u200F', '')
        .replaceAll('\u200E', '')
        .trim();
  }

  bool normalizeAndCompare(String a, String b) {
    return normalizeArabic(a) == normalizeArabic(b);
  }

  String fixArabicPresentationForms(String input) {
    final replacements = {
      // Alef - Enhanced mapping
      'ﺍ': 'ا', 'ﺎ': 'ا', 'ﺃ': 'أ', 'ﺄ': 'أ', 'ﺇ': 'إ', 'ﺈ': 'إ', 
      'ﺁ': 'آ', 'ﺂ': 'آ', 'ﺀ': 'ء',
      
      // Beh - Complete forms
      'ﺏ': 'ب', 'ﺑ': 'ب', 'ﺒ': 'ب', 'ﺐ': 'ب',
      
      // Teh Marbuta
      'ﺓ': 'ة', 'ﺔ': 'ة',
      
      // Teh - Complete forms
      'ﺕ': 'ت', 'ﺗ': 'ت', 'ﺘ': 'ت', 'ﺖ': 'ت',
      
      // Theh - Complete forms
      'ﺙ': 'ث', 'ﺛ': 'ث', 'ﺜ': 'ث', 'ﺚ': 'ث',
      
      // Jeem - Complete forms
      'ﺝ': 'ج', 'ﺟ': 'ج', 'ﺠ': 'ج', 'ﺞ': 'ج',
      
      // Hah - Complete forms
      'ﺡ': 'ح', 'ﺣ': 'ح', 'ﺤ': 'ح', 'ﺢ': 'ح',
      
      // Khah - Complete forms
      'ﺥ': 'خ', 'ﺧ': 'خ', 'ﺨ': 'خ', 'ﺦ': 'خ',
      
      // Dal - Complete forms
      'ﺩ': 'د', 'ﺪ': 'د',
      
      // Thal - Complete forms
      'ﺫ': 'ذ', 'ﺬ': 'ذ',
      
      // Reh - Complete forms
      'ﺭ': 'ر', 'ﺮ': 'ر',
      
      // Zain - Complete forms
      'ﺯ': 'ز', 'ﺰ': 'ز',
      
      // Seen - Complete forms
      'ﺱ': 'س', 'ﺳ': 'س', 'ﺴ': 's', 'ﺲ': 'س',
      
      // Sheen - Complete forms
      'ﺵ': 'ش', 'ﺷ': 'ش', 'ﺸ': 'ش', 'ﺶ': 'ش',
      
      // Sad - Complete forms
      'ﺹ': 'ص', 'ﺻ': 'ص', 'ﺼ': 'ص', 'ﺺ': 'ص',
      
      // Dad - Complete forms
      'ﺽ': 'ض', 'ﺿ': 'ض', 'ﻀ': 'ض', 'ﺾ': 'ض',
      
      // Tah - Complete forms
      'ﻁ': 'ط', 'ﻃ': 'ط', 'ﻄ': 'ط', 'ﻂ': 'ط',
      
      // Zah - Complete forms
      'ﻅ': 'ظ', 'ﻇ': 'ظ', 'ﻈ': 'ظ', 'ﻆ': 'ظ',
      
      // Ain - Complete forms
      'ﻉ': 'ع', 'ﻋ': 'ع', 'ﻌ': 'ع', 'ﻊ': 'ع',
      
      // Ghain - Complete forms
      'ﻍ': 'غ', 'ﻏ': 'غ', 'ﻐ': 'غ', 'ﻎ': 'غ',
      
      // Feh - Complete forms
      'ﻑ': 'ف', 'ﻓ': 'ف', 'ﻔ': 'ف', 'ﻒ': 'ف',
      
      // Qaf - Complete forms
      'ﻕ': 'ق', 'ﻗ': 'ق', 'ﻘ': 'ق', 'ﻖ': 'ق',
      
      // Kaf - Complete forms
      'ﻙ': 'ك', 'ﻛ': 'ك', 'ﻜ': 'ك', 'ﻚ': 'ك',
      
      // Lam - Complete forms
      'ﻝ': 'ل', 'ﻟ': 'ل', 'ﻠ': 'ل', 'ﻞ': 'ل',
      
      // Meem - Complete forms
      'ﻡ': 'م', 'ﻣ': 'م', 'ﻤ': 'م', 'ﻢ': 'م',
      
      // Noon - Complete forms
      'ﻥ': 'ن', 'ﻧ': 'ن', 'ﻨ': 'ن', 'ﻦ': 'ن',
      
      // Heh - Complete forms
      'ﻩ': 'ه', 'ﻫ': 'ه', 'ﻬ': 'ه', 'ﻪ': 'ه',
      
      // Waw - Complete forms
      'ﻭ': 'و', 'ﻮ': 'و', 'ﺅ': 'ؤ', 'ﺆ': 'ؤ',
      
      // Yeh - Complete forms
      'ﻱ': 'ي', 'ﻳ': 'ي', 'ﻴ': 'ي', 'ﻲ': 'ي', 
      'ﻯ': 'ى', 'ﻰ': 'ى', 'ﺉ': 'ئ', 'ﺊ': 'ئ', 
      'ﺋ': 'ئ', 'ﺌ': 'ئ',
      
      // Lam-Alef combinations
      'ﻻ': 'لا', 'ﻼ': 'لا', 'ﻷ': 'لأ', 'ﻸ': 'لأ',
      'ﻹ': 'لإ', 'ﻺ': 'لإ', 'ﻵ': 'لآ', 'ﻶ': 'لآ',
      
      // Additional presentation forms
      'ﱞ': 'تج', 'ﱟ': 'تح', 'ﱠ': 'تخ', 'ﱡ': 'تم', 'ﱢ': 'تى', 'ﱣ': 'تي',
      'ﱤ': 'ثج', 'ﱥ': 'ثم', 'ﱦ': 'ثى', 'ﱧ': 'ثي',
      'ﱨ': 'جح', 'ﱩ': 'جم', 'ﱪ': 'حج', 'ﱫ': 'حم',
      'ﱬ': 'خج', 'ﱭ': 'خح', 'ﱮ': 'خم',
      'ﱯ': 'سج', 'ﱰ': 'سح', 'ﱱ': 'سخ', 'ﱲ': 'سم',
      'ﱳ': 'صح', 'ﱴ': 'صم', 'ﱵ': 'ضج', 'ﱶ': 'ضح',
      'ﱷ': 'ضخ', 'ﱸ': 'ضم', 'ﱹ': 'طح', 'ﱺ': 'طم',
      'ﱻ': 'ظم', 'ﱼ': 'عج', 'ﱽ': 'عم', 'ﱾ': 'غج',
      'ﱿ': 'غم', 'ﲀ': 'فج', 'ﲁ': 'فح', 'ﲂ': 'فخ',
      'ﲃ': 'فم', 'ﲄ': 'فى', 'ﲅ': 'في', 'ﲆ': 'قح',
      'ﲇ': 'قم', 'ﲈ': 'قى', 'ﲉ': 'قي', 'ﲊ': 'كا',
      'ﲋ': 'كج', 'ﲌ': 'كح', 'ﲍ': 'كخ', 'ﲎ': 'كل',
      'ﲏ': 'كم', 'ﲐ': 'كى', 'ﲑ': 'كي', 'ﲒ': 'لج',
      'ﲓ': 'لح', 'ﲔ': 'لخ', 'ﲕ': 'لم', 'ﲖ': 'لى',
      'ﲗ': 'لي', 'ﲘ': 'مج', 'ﲙ': 'مح', 'ﲚ': 'مخ',
      'ﲛ': 'مم', 'ﲜ': 'مى', 'ﲝ': 'مي', 'ﲞ': 'نج',
      'ﲟ': 'نح', 'ﲠ': 'نخ', 'ﲡ': 'نم', 'ﲢ': 'نى',
      'ﲣ': 'ني', 'ﲤ': 'هج', 'ﲥ': 'هم', 'ﲦ': 'هى',
      'ﲧ': 'هي', 'ﲨ': 'يج', 'ﲩ': 'يح', 'ﲪ': 'يخ',
      'ﲫ': 'يم', 'ﲬ': 'يى', 'ﲭ': 'يي',
      
      // Persian and Urdu letters (if needed)
      'ﭘ': 'پ', 'ﭙ': 'پ', 'ﭚ': 'پ', 'ﭛ': 'پ',
      'ﭼ': 'چ', 'ﭽ': 'چ', 'ﭾ': 'چ', 'ﭿ': 'چ',
      'ﮊ': 'ژ', 'ﮋ': 'ژ',
      'ﮎ': 'ک', 'ﮏ': 'ک', 'ﮐ': 'ک', 'ﮑ': 'ک',
      'ﮒ': 'گ', 'ﮓ': 'گ', 'ﮔ': 'گ', 'ﮕ': 'گ',
      'ﯼ': 'ی', 'ﯽ': 'ی', 'ﯾ': 'ی', 'ﯿ': 'ی',
    };

    return input.split('').map((char) => replacements[char] ?? char).join();
  }

  Widget _buildCameraPreview() {
    return ClipRect(
      child: Transform.scale(
        scale: _cameraController!.value.aspectRatio / MediaQuery.of(context).size.aspectRatio,
        child: Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = predictedObject != null &&
        randomTarget != null &&
        normalizeAndCompare(predictedObject!, randomTarget!);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          S.of(context).level_one_live_camera,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, size: 28),
              onPressed: () {
                setState(() {
                  completedWords.clear();
                  score = 0;
                  allCompleted = false;
                });
                pickRandomWord();
                _startContinuousDetection();
              },
              tooltip: S.of(context).new_word,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced target word display
          if (!allCompleted)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tablet_outlined, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        S.of(context).target_word,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      randomTarget ?? "",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 1.5,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          if (allCompleted)
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                  SizedBox(height: 16),
                  Text(
                    S.of(context).congratsAllWordsCompleted,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          // Enhanced camera preview with full width
          if (!allCompleted)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _isCameraInitialized
                      ? Stack(
                          children: [
                            // Full width camera preview
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _cameraController!.value.previewSize!.height,
                                  height: _cameraController!.value.previewSize!.width,
                                  child: CameraPreview(_cameraController!),
                                ),
                              ),
                            ),
                          
                            // Detection overlay
                            if (isDetecting)
                              Container(
                                color: Colors.black.withOpacity(0.4),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                          S.of(context).analyzing,
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          
                            // Enhanced crosshair/target indicator
                            Center(
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red.shade400,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  children: [
                                    // Corner brackets
                                    Positioned(
                                      top: -3,
                                      left: -3,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.red.shade400, width: 4),
                                            left: BorderSide(color: Colors.red.shade400, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -3,
                                      right: -3,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.red.shade400, width: 4),
                                            right: BorderSide(color: Colors.red.shade400, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -3,
                                      left: -3,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.red.shade400, width: 4),
                                            left: BorderSide(color: Colors.red.shade400, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -3,
                                      right: -3,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.red.shade400, width: 4),
                                            right: BorderSide(color: Colors.red.shade400, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Center crosshair
                                    Center(
                                      child: Icon(
                                        Icons.center_focus_strong,
                                        color: Colors.red.shade400,
                                        size: 60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                          strokeWidth: 4,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        S.of(context).preparing_camera,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          
          // Enhanced results section
          if (!allCompleted)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (predictedObject != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, color: Colors.blue.shade600, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${S.of(context).result}: $predictedObject",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isCorrect ? S.of(context).correct_answer : S.of(context).try_again,
                              style: TextStyle(
                                color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCorrect && showNextButton)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 10),
                        child: ElevatedButton.icon(
                          onPressed: handleNext,
                          icon: Icon(Icons.navigate_next, size: 24),
                          label: Text(
                            S.of(context).next,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.blue.shade600,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              S.of(context).point_camera_instruction,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}