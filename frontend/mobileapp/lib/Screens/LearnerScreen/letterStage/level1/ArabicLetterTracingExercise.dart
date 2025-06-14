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
  List<List<Offset>> strokes = <List<Offset>>[];
  List<Offset> currentStroke = <Offset>[];
  final GlobalKey _paintKey = GlobalKey();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isCorrectTracing = false;
  double _accuracy = 0.0;
  bool _isDrawing = false;

  // For letter shape analysis
  List<Offset> _letterPixels = [];
  late Size _canvasSize;

  @override
  void initState() {
    super.initState();
    _initTts();
    _canvasSize = const Size(300, 300);
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

  // Enhanced letter shape generation for better coverage detection
  List<Offset> _generateLetterShape(String letter, Size canvasSize) {
    List<Offset> letterPoints = [];

    // Calculate letter dimensions and position
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: canvasSize.width * 0.6,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: canvasSize.width);

    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    final letterWidth = textPainter.width;
    final letterHeight = textPainter.height;

    // TECHNIQUE: Multi-layer point generation for comprehensive coverage detection

    // Layer 1: Dense core grid (primary letter area)
    for (double x = centerX - letterWidth / 2; x <= centerX + letterWidth / 2; x += 5) {
      for (double y = centerY - letterHeight / 2; y <= centerY + letterHeight / 2; y += 5) {
        letterPoints.add(Offset(x, y));
      }
    }

    // Layer 2: Perimeter outline points (letter boundaries)
    final steps = 50;
    for (int i = 0; i < steps; i++) {
      double t = i / steps;

      // Top edge
      letterPoints.add(Offset(
          centerX - letterWidth / 2 + (letterWidth * t),
          centerY - letterHeight / 2
      ));

      // Bottom edge
      letterPoints.add(Offset(
          centerX - letterWidth / 2 + (letterWidth * t),
          centerY + letterHeight / 2
      ));

      // Left edge
      letterPoints.add(Offset(
          centerX - letterWidth / 2,
          centerY - letterHeight / 2 + (letterHeight * t)
      ));

      // Right edge
      letterPoints.add(Offset(
          centerX + letterWidth / 2,
          centerY - letterHeight / 2 + (letterHeight * t)
      ));
    }

    // Layer 3: Cross-pattern for better shape detection
    for (double t = 0; t <= 1; t += 0.02) {
      // Horizontal line through center
      letterPoints.add(Offset(
          centerX - letterWidth / 2 + (letterWidth * t),
          centerY
      ));

      // Vertical line through center
      letterPoints.add(Offset(
          centerX,
          centerY - letterHeight / 2 + (letterHeight * t)
      ));
    }

    print("Generated ${letterPoints.length} reference points for letter '$letter'");
    return letterPoints;
  }

  // Calculate similarity between user drawing and letter shape
  // Made more forgiving for dyslexic users

// PRIMARY FOCUS: Letter Coverage Accuracy Calculation
  double _calculateLetterSimilarity() {
    if (strokes.isEmpty) return 0.0;

    final currentLetter = arabicLetters[currentLetterIndex];
    final letterShape = _generateLetterShape(currentLetter, _canvasSize);

    // Get all user drawn points
    List<Offset> userPoints = [];
    for (var stroke in strokes) {
      userPoints.addAll(stroke);
    }

    if (userPoints.isEmpty) return 0.0;

    // MAIN FACTOR: Letter Coverage Analysis (85% weight)
    double totalLetterPoints = letterShape.length.toDouble();
    double coveredLetterPoints = 0.0;

    print("Total letter reference points: ${totalLetterPoints.toInt()}");
    print("User drawn points: ${userPoints.length}");

    // Calculate how many letter points are covered by user drawing
    for (Offset letterPoint in letterShape) {
      bool isCovered = false;

      for (Offset userPoint in userPoints) {
        double distance = (letterPoint - userPoint).distance;

        // Tolerance for considering a point "covered"
        if (distance <= 40.0) {
          isCovered = true;
          break;
        }
      }

      if (isCovered) {
        coveredLetterPoints++;
      }
    }

    // Calculate the raw coverage percentage
    double coveragePercentage = totalLetterPoints > 0
        ? (coveredLetterPoints / totalLetterPoints)
        : 0.0;

    print("Covered letter points: ${coveredLetterPoints.toInt()}");
    print("Raw coverage percentage: ${(coveragePercentage * 100).toStringAsFixed(1)}%");

    // TECHNIQUE: Accuracy Zones for Different Coverage Levels
    double adjustedCoverage = 0.0;

    if (coveragePercentage >= 0.7) {
      // Excellent coverage (70%+) - Full score with bonus
      adjustedCoverage = (coveragePercentage * 1.1).clamp(0.0, 1.0);
    } else if (coveragePercentage >= 0.5) {
      // Good coverage (50-69%) - Slight boost
      adjustedCoverage = (coveragePercentage * 1.05).clamp(0.0, 1.0);
    } else if (coveragePercentage >= 0.3) {
      // Fair coverage (30-49%) - No adjustment
      adjustedCoverage = coveragePercentage;
    } else if (coveragePercentage >= 0.15) {
      // Poor coverage (15-29%) - Slight penalty but still some credit
      adjustedCoverage = coveragePercentage * 0.9;
    } else {
      // Very poor coverage (<15%) - Minimal credit
      adjustedCoverage = coveragePercentage * 0.7;
    }

    // MINOR FACTORS: Basic Quality Checks (15% weight total)

    // Check 1: Minimum effort (5% weight)
    double effortScore = 0.0;
    if (userPoints.length >= 8) {
      effortScore = 0.3;
      if (userPoints.length >= 15) effortScore = 0.6;
      if (userPoints.length >= 25) effortScore = 1.0;
    }

    // Check 2: Drawing spread (5% weight)
    double spreadScore = 0.0;
    if (userPoints.length > 1) {
      double minX = userPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      double maxX = userPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
      double minY = userPoints.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
      double maxY = userPoints.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

      double width = maxX - minX;
      double height = maxY - minY;

      if (width > 20 && height > 20) spreadScore = 0.4;
      if (width > 40 && height > 40) spreadScore = 0.7;
      if (width > 60 && height > 60) spreadScore = 1.0;
    }

    // Check 3: Stroke continuity (5% weight)
    double continuityScore = 0.0;
    if (strokes.isNotEmpty) {
      continuityScore = 0.5; // Base score for any drawing
      if (strokes.length >= 2) continuityScore = 0.8; // Multi-stroke bonus
      if (strokes.length >= 3) continuityScore = 1.0; // Complex letter bonus
    }

    // FINAL CALCULATION: Coverage is the dominant factor
    double finalScore = (
        adjustedCoverage * 0.85 +           // 85% - Letter coverage accuracy
            effortScore * 0.05 +                // 5% - Drawing effort
            spreadScore * 0.05 +                // 5% - Drawing spread
            continuityScore * 0.05              // 5% - Stroke continuity
    ).clamp(0.0, 1.0);

    print("Final coverage score: ${(finalScore * 100).toStringAsFixed(1)}%");
    print("Coverage component: ${(adjustedCoverage * 0.85 * 100).toStringAsFixed(1)}%");
    print("Quality components: ${((effortScore * 0.05 + spreadScore * 0.05 + continuityScore * 0.05) * 100).toStringAsFixed(1)}%");

    return finalScore;
  }

// Updated validation with coverage-focused messaging
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

    // Calculate coverage accuracy
    double coverageAccuracy = _calculateLetterSimilarity();

    setState(() {
      _accuracy = coverageAccuracy;
      // Coverage-focused threshold: 35% coverage required
      _isCorrectTracing = coverageAccuracy >= 0.35;
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
            Text("Great! You covered the letter shape accurately."),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _accuracy,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              "Letter Coverage: ${(_accuracy * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _accuracy >= 0.7 ? "Excellent coverage!" :
              _accuracy >= 0.5 ? "Good coverage!" :
              "Adequate coverage!",
              style: TextStyle(
                color: _accuracy >= 0.7 ? Colors.green :
                _accuracy >= 0.5 ? Colors.blue : Colors.orange,
                fontSize: 12,
              ),
            ),
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
        title: Row(
          children: [
            const Icon(Icons.close_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(S.of(context).tryAgain3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You need to cover more of the letter '${arabicLetters[currentLetterIndex]}' shape. Try tracing over more parts of the letter."),
            const SizedBox(height: 16),
            if (_accuracy > 0) ...[
              LinearProgressIndicator(
                value: _accuracy,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                "Letter Coverage: ${(_accuracy * 100).toStringAsFixed(0)}% (need 35%+)",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Tip: Draw over more areas of the letter to increase coverage",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
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
                              painter: AccurateTracingPainter(
                                letter: currentLetter,
                                strokes: strokes,
                                currentStroke: currentStroke,
                                showGuideLines: true,
                              ),
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
                  if (_accuracy > 0)
                    Text(
                      "Accuracy: ${(_accuracy * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: _accuracy >= 0.6 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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

// Improved painter with better letter validation
class AccurateTracingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final bool showGuideLines;

  AccurateTracingPainter({
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

      // Center guidelines
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        gridPaint,
      );
    }

    // Draw the letter as a light watermark in the background
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.width * 0.6,
          color: Colors.grey.withOpacity(0.15),
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
  bool shouldRepaint(AccurateTracingPainter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}