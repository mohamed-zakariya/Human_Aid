import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../generated/l10n.dart';

class ArabicLetterTracingExercise extends StatefulWidget {
  const ArabicLetterTracingExercise({Key? key}) : super(key: key);

  @override
  State<ArabicLetterTracingExercise> createState() => _ArabicLetterTracingExerciseState();
}

class _ArabicLetterTracingExerciseState extends State<ArabicLetterTracingExercise> {
  final List<String> arabicLetters = [
    'أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ',
    'د', 'ذ', 'ر', 'ز', 'س', 'ش',
    'ص', 'ض', 'ط', 'ظ', 'ع', 'غ',
    'ف', 'ق', 'ك', 'ل', 'م', 'ن',
    'هـ', 'و', 'ي'
  ];
  int currentLetterIndex = 0;
  final Path _userPath = Path();
  Offset? _lastPoint;
  final GlobalKey _paintKey = GlobalKey();
  final FlutterTts _flutterTts = FlutterTts();

  void _showInstructions() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final instructionText = S.of(context).instructions;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.of(context).howToTrace,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      await _flutterTts.setLanguage(isArabic ? 'ar' : 'en');
                      await _flutterTts.setSpeechRate(0.5);
                      await _flutterTts.speak(instructionText);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                instructionText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _flutterTts.stop();
                  Navigator.pop(context);
                },
                child: Text(S.of(context).gotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = _paintKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    setState(() {
      if (_lastPoint == null) {
        _userPath.moveTo(localPosition.dx, localPosition.dy);
      } else {
        _userPath.lineTo(localPosition.dx, localPosition.dy);
      }
      _lastPoint = localPosition;
    });
  }

  void _onPanEnd(_) {
    _lastPoint = null;
  }

  void _clearTracing() {
    setState(() {
      _userPath.reset();
    });
  }

  Future<void> _onTracingComplete() async {
    bool isCorrect = await _validateTraceAccuracy();
    if (isCorrect) {
      if (currentLetterIndex < arabicLetters.length - 1) {
        setState(() {
          currentLetterIndex++;
          _userPath.reset();
        });
      } else {
        _showEncouragementMessage();
      }
    } else {
      _showTryAgainMessage();
    }
  }

  Future<bool> _validateTraceAccuracy() async {
    RenderRepaintBoundary boundary = _paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) return false;

    int tracedPixels = 0;
    for (int i = 0; i < byteData.lengthInBytes; i += 4) {
      int r = byteData.getUint8(i);
      int g = byteData.getUint8(i + 1);
      int b = byteData.getUint8(i + 2);
      int a = byteData.getUint8(i + 3);
      if (g > 100 && r < 100 && b < 100 && a > 0) {
        tracedPixels++;
      }
    }

    int totalPixels = (image.width * image.height).toInt();
    return tracedPixels > totalPixels * 0.01;
  }

  void _showEncouragementMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).greatJob2),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentLetterIndex = 0;
                _userPath.reset();
              });
            },
            child: Text(S.of(context).restart),
          ),
        ],
      ),
    );
  }

  void _showTryAgainMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).tryAgain3),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearTracing();
            },
            child: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentLetter = arabicLetters[currentLetterIndex];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.of(context).traceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: RepaintBoundary(
                      key: _paintKey,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: GestureDetector(
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            painter: TracingPainter(letter: currentLetter, userPath: _userPath),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _onTracingComplete,
                  label: Text(S.of(context).done),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearTracing,
                  label: Text(S.of(context).clear),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final String letter;
  final Path userPath;

  TracingPainter({required this.letter, required this.userPath});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.width * 0.7,
          color: Colors.grey.withOpacity(0.3),
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: size.width);
    final Offset offset = Offset(
      size.width / 2 - textPainter.width / 2,
      size.height / 2 - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);

    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 255, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawPath(userPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
