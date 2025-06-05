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
  List<List<Offset>> strokes = <List<Offset>>[];  // Multiple strokes
  List<Offset> currentStroke = <Offset>[];        // Current stroke being drawn
  final GlobalKey _paintKey = GlobalKey();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isCorrectTracing = false;
  double _accuracy = 0.0;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

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
                  const Icon(Icons.info_outline, color: Color(0xFF7F6DF3)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F6DF3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(S.of(context).gotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_paintKey.currentContext == null) return;

    RenderBox renderBox = _paintKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _isDrawing = true;
      currentStroke = [localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing || _paintKey.currentContext == null) return;

    RenderBox renderBox = _paintKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      currentStroke.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _isDrawing = false;
      if (currentStroke.isNotEmpty) {
        strokes.add(List.from(currentStroke));
        currentStroke = [];
      }

      // We're not validating against any specific path, so just check
      // if they've drawn something substantial
      _checkDrawingProgress();
    });
  }

  void _clearTracing() {
    setState(() {
      strokes.clear();
      currentStroke = [];
      _isCorrectTracing = false;
      _accuracy = 0.0;
    });
  }

  void _checkDrawingProgress() {
    // Simple check - if they've drawn enough strokes
    if (strokes.isEmpty) return;

    int totalPoints = 0;
    for (var stroke in strokes) {
      totalPoints += stroke.length;
    }

    // Consider any drawing as valid - we're not checking against template
    if (totalPoints > 20) {
      setState(() {
        _accuracy = 0.8; // High accuracy since we're not validating against a template
        _isCorrectTracing = true;
      });
    }
  }

  Future<void> _validateTracingFeedback() async {
    if (strokes.isEmpty && currentStroke.isEmpty) {
      _showTryAgainMessage();
      return;
    }

    // Finalize the current stroke if any
    if (currentStroke.isNotEmpty) {
      setState(() {
        strokes.add(List.from(currentStroke));
        currentStroke = [];
      });
    }

    // Simply check if the user has drawn something
    int totalPoints = 0;
    for (var stroke in strokes) {
      totalPoints += stroke.length;
    }

    setState(() {
      // Any drawing is considered valid
      _accuracy = totalPoints > 20 ? 0.9 : totalPoints / 22.0;
      _accuracy = _accuracy > 1.0 ? 1.0 : _accuracy;

      // Consider it correct if they drew anything substantial
      _isCorrectTracing = totalPoints > 15;
    });

    if (_isCorrectTracing) {
      _showSuccessMessage();
    } else {
      _showTryAgainMessage();
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(S.of(context).wellDone),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).youTracedCorrectly),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _accuracy,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text("${(_accuracy * 100).toStringAsFixed(0)}% ${S.of(context).accuracy}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentLetterIndex < arabicLetters.length - 1) {
                setState(() {
                  currentLetterIndex++;
                  strokes.clear();
                  currentStroke = [];
                  _isCorrectTracing = false;
                  _accuracy = 0.0;
                });
              } else {
                _showEncouragementMessage();
              }
            },
            child: Text(
              S.of(context).next,
              style: const TextStyle(color: Color(0xFF7F6DF3)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEncouragementMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(S.of(context).greatJob2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You've completed tracing all the Arabic letters! Great job!"),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/celebration.png',
              height: 100,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.celebration, size: 60, color: Colors.amber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentLetterIndex = 0;
                strokes.clear();
                currentStroke = [];
                _isCorrectTracing = false;
                _accuracy = 0.0;
              });
            },
            child: Text(
              S.of(context).restart,
              style: const TextStyle(color: Color(0xFF7F6DF3)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTryAgainMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).tryAgain3),
        content: const Text("Please draw something to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearTracing();
            },
            child: Text(
              S.of(context).retry,
              style: const TextStyle(color: Color(0xFF7F6DF3)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;


    String currentLetter = arabicLetters[currentLetterIndex];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.of(context).traceTitle),
        backgroundColor: const Color(0xFF7F6DF3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFF7F6DF3),
              child: Row(
                children: [
                  Text(
                    "${currentLetterIndex + 1}/${arabicLetters.length}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentLetterIndex + 1) / arabicLetters.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Letter display and information
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F6DF3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentLetter,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F6DF3),
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).drawLetter(currentLetter),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.of(context).drawInstruction,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: const Color(0xFF7F6DF3),
                    onPressed: () async {
                      await _flutterTts.speak(currentLetter);
                    },
                  ),
                ],
              ),
            ),

            // Tracing area
            Expanded(
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isCorrectTracing ? Colors.green : const Color(0xFF7F6DF3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: RepaintBoundary(
                        key: _paintKey,
                        child: Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: CustomPaint(
                              painter: FreeDrawingPainter(
                                letter: currentLetter,
                                strokes: strokes,
                                currentStroke: currentStroke,
                                showGuideLines: true,
                              ),
                              // Make sure the painter fills the entire area
                              size: const Size(300, 300),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Debug info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).strokeCount(strokes.length),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    S.of(context).pointCount(
                        strokes.fold(0, (sum, stroke) => sum + stroke.length) + currentStroke.length
                    ),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Clear button
                  ElevatedButton.icon(
                    onPressed: _clearTracing,
                    icon: const Icon(Icons.refresh),
                    label: Text(S.of(context).clear),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),

                  // Check button
                  ElevatedButton.icon(
                    onPressed: () => _validateTracingFeedback(),
                    icon: const Icon(Icons.check),
                    label: Text(S.of(context).done),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F6DF3),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Free drawing painter that doesn't enforce tracing along a specific path
class FreeDrawingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final bool showGuideLines;

  FreeDrawingPainter({
    required this.letter,
    required this.strokes,
    required this.currentStroke,
    this.showGuideLines = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clear the canvas with white background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw background grid for guidance (optional)
    if (showGuideLines) {
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Horizontal lines
      for (double y = 0; y < size.height; y += size.height / 6) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      // Vertical lines
      for (double x = 0; x < size.width; x += size.width / 6) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    // Draw the letter as a watermark in the background
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.width * 0.6,
          color: Colors.grey.withOpacity(0.2),  // Make it more faded
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

    // Draw the completed strokes
    final strokePaint = Paint()
      ..color = const Color(0xFF7F6DF3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, strokePaint);
    }

    // Draw the current stroke being drawn
    if (currentStroke.length >= 2) {
      final path = Path();
      path.moveTo(currentStroke[0].dx, currentStroke[0].dy);

      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }

      canvas.drawPath(path, strokePaint);
    } else if (currentStroke.length == 1) {
      // Draw a single point
      canvas.drawCircle(currentStroke[0], 3.0, strokePaint);
    }
  }

  @override
  bool shouldRepaint(FreeDrawingPainter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}