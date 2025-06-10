import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../../generated/l10n.dart';
import 'direction_game2_page.dart';

class DirectionInstructionsSecondPage extends StatefulWidget {
  @override
  _DirectionInstructionsSecondPageState createState() =>
      _DirectionInstructionsSecondPageState();
}

class _DirectionInstructionsSecondPageState extends State<DirectionInstructionsSecondPage> {
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> directions = {
    '⬆': 'أعلى',
    '⬇': 'أسفل',
    '➡': 'يمين',
    '⬅': 'يسار',
    '↗': 'أعلى اليمين',
    '↘': 'أسفل اليمين',
    '↖': 'أعلى اليسار',
    '↙': 'أسفل اليسار',
  };

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> speakDirection(String direction, String meaning) async {
    final loc = S.of(context);

    // Speak the direction pronunciation
    final speechText = loc.speakDirectionTemplate(meaning);
    await flutterTts.speak(speechText);  }

  Future<void> speakInstructions() async {
    final loc = S.of(context);
    await flutterTts.speak(loc.instructionSpeech);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final loc = S.of(context);


    double screenWidth = MediaQuery.of(context).size.width;
    double baseFontSize = screenWidth < 360 ? 14 : 16;

    return Scaffold(
      backgroundColor: const Color(0xFF8674F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // Reduced height
        child: AppBar(
          backgroundColor: const Color(0xFF8674F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 10),
            child: Center(
              child: Text(
                args['gameName'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game instructions section with TTS icon
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Color(0xFF7367F0)),
                            onPressed: speakInstructions,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            loc.exerciseInfoTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer, color: Color(0xFF7367F0)),
                              const SizedBox(width: 8),
                              Flexible(child: Text(loc.timerInfo)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.touch_app, color: Color(0xFF7367F0)),
                              const SizedBox(width: 8),
                              Flexible(child: Text(loc.dragInfo)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Color(0xFF7367F0)),
                              const SizedBox(width: 8),
                              Flexible(child: Text(loc.correctDirectionInfo)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Start button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7367F0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DirectionGameSecondPage(totalQuestions: 10),
                            ),
                          );
                        },
                        icon: const Icon(Icons.school, color: Colors.white),
                        label: Text(
                          loc.startExercise,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 10),
                      child: Text(
                        loc.directionsTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 20),
                      child: Text(
                        loc.tapToHearDirection,
                        style: TextStyle(
                          fontSize: baseFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: directions.length,
                      itemBuilder: (context, index) {
                        final entry = directions.entries.elementAt(index);
                        return InkWell(
                          onTap: () async {
                            // First attempt: Speak direction
                            await speakDirection(entry.key, entry.value);
                            // // Second attempt: Allow user to listen again
                            // Timer(const Duration(seconds: 5), () => speakDirection(entry.key, entry.value));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF7367F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
