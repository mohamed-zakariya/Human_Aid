// lib/Screens/LearnerScreen/letterStage/Level2/letter_level2.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../generated/l10n.dart';
import '../../../../graphql/graphql_client.dart';
import '../../../../graphql/queries/letters_excercise_query.dart';
import '../../../../services/letters_service.dart';
import '../../../../services/audio_service.dart';
import '../../../../services/speech_service.dart';
import '../../../../services/tts_service.dart'; // Import the new TTSService
import '../../../../models/letter.dart';
import '../../../../models/learner.dart';

class LetterLevel2 extends StatefulWidget {
  final String exerciseId;   // Mongo _id
  final Learner learner;     // contains learner.id

  const LetterLevel2({
    Key? key,
    required this.exerciseId,
    required this.learner,
  }) : super(key: key);

  @override
  State<LetterLevel2> createState() => _LetterLevel2State();
}

class _LetterLevel2State extends State<LetterLevel2> {
  // ─── controllers ───
  final CarouselSliderController _carousel = CarouselSliderController();
  final TTSService _tts = TTSService(); // Replace AudioPlayer with TTSService
  final AudioService _recorder = AudioService();

  // ─── state ───
  List<Letter> _letters = [];
  bool _loading   = true;
  bool _recording = false;
  int  _current   = 0;

  // IDs
  late final String userId;
  late final String exerciseId;

  @override
  void initState() {
    super.initState();
    userId     = widget.learner.id!;   // valid ObjectId
    exerciseId = widget.exerciseId;
    _tts.initialize(language: 'ar-EG'); // Initialize TTS with Arabic language
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    // 1. start exercise
    GraphQLService.getClient().then((c) => c.mutate(
          MutationOptions(
            document : gql(startExerciseMutation),
            variables: {'userId': userId, 'exerciseId': exerciseId},
          ),
        ));

    // 2. fetch letters
    final fetched = await LettersService.getLettersForLevel2();
    setState(() {
      _letters = fetched ??
          _fallbackArabicLetters
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

  // ─── helpers ───
  Future<void> _play(String glyph) async {
    await _tts.speak(glyph); // Use TTS to speak the letter
  }

  Future<void> _toggleRecord(int idx) async {
    if (!_recording) {
      await _recorder.startRecording();
      setState(() => _recording = true);
      return;
    }

    setState(() => _recording = false);
    final path = await _recorder.stopRecording();
    if (path == null) return;

    final res = await SpeechService.processSpeech(
      userId        : userId,
      exerciseId    : exerciseId,
      wordId        : _letters[idx].id,
      correctWord   : _letters[idx].letter,
      audioFilePath : path,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res?['message'] ?? S.of(context).errorTryAgain),
        backgroundColor:
            (res?['isCorrect'] ?? false) ? Colors.green : Colors.red,
      ),
    );
  }

  // ─── original card design ───
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
                    style:
                        TextStyle(color: _recording ? Colors.white : color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── build ───
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

  // ─── cleanup ───
  @override
  void dispose() {
    _tts.dispose(); // Dispose the TTS service
    _recorder.dispose();
    GraphQLService.getClient().then((c) => c.mutate(MutationOptions(
          document: gql(endExerciseMutation),
          variables: {'userId': userId, 'exerciseId': exerciseId},
        )));
    super.dispose();
  }

  // ─── fallback letters & color list (unchanged) ───
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