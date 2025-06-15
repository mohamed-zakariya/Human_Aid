// lib/Screens/LearnerScreen/letterStage/Level2/letter_level2.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../Services/letters_exercise_service.dart';
import '../../../../generated/l10n.dart';
import '../../../../graphql/graphql_client.dart';
import '../../../../graphql/queries/letters_excercise_query.dart';
import '../../../../services/audio_service.dart';
import '../../../../services/tts_service.dart';
import '../../../../models/letter.dart';
import '../../../../models/learner.dart';

class LetterLevel2 extends StatefulWidget {
  final String exerciseId;
  final String levelId;
  final Learner learner;

  const LetterLevel2({
    Key? key,
    required this.exerciseId,
    required this.levelId,
    required this.learner,
  }) : super(key: key);

  @override
  State<LetterLevel2> createState() => _LetterLevel2State();
}

class _LetterLevel2State extends State<LetterLevel2> {
  // ─── controllers ───
  final CarouselSliderController _carousel = CarouselSliderController();
  final TTSService _tts = TTSService();
  final AudioService _recorder = AudioService();

  // ─── state ───
  List<Letter> _letters = [];
  bool _loading = true;
  bool _recording = false;
  int _current = 0;
  
  // New state for transcript display
  String? _lastTranscript;
  bool _showTranscript = false;
  bool _isCorrect = false;
  String? _feedbackMessage;

  // IDs
  late final String userId;
  late final String exerciseId;
  late final String levelId;

  @override
  void initState() {
    super.initState();
    userId = widget.learner.id!;
    exerciseId = widget.exerciseId;
    levelId = widget.levelId;
    _tts.initialize(language: 'ar-EG');
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    await LetterExerciseService.startExercise(userId, exerciseId);

    try {
      final fetched = await LetterExerciseService.fetchLetters();
      setState(() {
        _letters = fetched;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _letters = _fallbackArabicLetters
            .asMap()
            .entries
            .map((e) => Letter(
                  id: '${e.key}',
                  letter: e.value,
                  group: '',
                ))
            .toList();
        _loading = false;
      });
    }
  }

  Future<void> _play(String glyph) async {
    await _tts.speak(glyph);
  }

  Future<void> _toggleRecord(int idx) async {
    if (!_recording) {
      // Clear previous results when starting new recording
      setState(() {
        _showTranscript = false;
        _lastTranscript = null;
        _feedbackMessage = null;
      });
      
      await _recorder.startRecording();
      setState(() => _recording = true);
      return;
    }

    setState(() => _recording = false);
    final path = await _recorder.stopRecording();
    if (path == null) return;

    // Show loading indicator
    _showTranscriptDialog(isLoading: true);

    final res = await LetterExerciseService.submitLetter(
      userId: userId,
      exerciseId: exerciseId,
      levelId: levelId,
      letter: _letters[idx],
      recordingPath: path,
    );

    if (!mounted) return;

    // Update state with results
    setState(() {
      _lastTranscript = res['transcript'];
      _isCorrect = res['isCorrect'] ?? false;
      _feedbackMessage = res['message'];
      _showTranscript = true;
    });

    // Close loading dialog and show results
    Navigator.of(context).pop();
    _showTranscriptDialog();
  }

  void _showTranscriptDialog({bool isLoading = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: isLoading
                ? _buildLoadingContent()
                : _buildTranscriptContent(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
        const SizedBox(height: 16),
        Text(
          'جاري معالجة التسجيل...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTranscriptContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success/Error Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _isCorrect ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        
        // Status Text
        Text(
          _isCorrect ? 'ممتاز!' : 'محاولة جيدة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isCorrect ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 12),
        
        // Expected vs Spoken
        if (_lastTranscript != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'المطلوب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _letters[_current].letter,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'ما قلته',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isCorrect 
                                  ? Colors.green.shade50 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _lastTranscript!.isNotEmpty 
                                  ? _lastTranscript! 
                                  : 'غير واضح',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Feedback Message
        if (_feedbackMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _feedbackMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _play(_letters[_current].letter);
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('استمع مرة أخرى'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('إغلاق'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLetterCard({
    required Letter ltr,
    required Color color,
    required int index,
  }) {
    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      ltr.letter,
                      style: const TextStyle(
                        fontSize: 250,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                  ),
                  onPressed: () => _play(ltr.letter),
                  icon: const Icon(Icons.volume_up),
                  label: Text(S.of(context).listen),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _recording ? Colors.red : Colors.white,
                    foregroundColor: _recording ? Colors.white : color,
                    side: BorderSide(color: color, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                  ),
                  onPressed: () => _toggleRecord(index),
                  icon: Icon(
                    _recording ? Icons.stop : Icons.mic,
                    color: _recording ? Colors.white : color,
                  ),
                  label: Text(
                    _recording ? S.of(context).stop : S.of(context).recordYourVoice,
                    style: TextStyle(color: _recording ? Colors.white : color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: Text(S.of(context).letterLevel2),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                CarouselSlider.builder(
                  carouselController: _carousel,
                  itemCount: _letters.length,
                  itemBuilder: (_, index, __) => buildLetterCard(
                    ltr: _letters[index],
                    color: _colors[index % _colors.length],
                    index: index,
                  ),
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.65,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: false,
                    viewportFraction: 0.8,
                    onPageChanged: (i, _) => setState(() => _current = i),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => _carousel.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _carousel.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tts.dispose();
    _recorder.dispose();
    LetterExerciseService.endExercise(userId, exerciseId);
    super.dispose();
  }

  static const _fallbackArabicLetters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د',
    'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط',
    'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م',
    'ن', 'ه', 'و', 'ي',
  ];

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.cyan,
    Colors.deepPurple,
    Colors.lime,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.brown,
    Colors.pinkAccent,
    Colors.indigoAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
  ];
}