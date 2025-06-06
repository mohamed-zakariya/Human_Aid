import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'direction_game1_page.dart';

class DirectionInstructionsPage extends StatefulWidget {
  @override
  _DirectionInstructionsPageState createState() =>
      _DirectionInstructionsPageState();
}

class _DirectionInstructionsPageState extends State<DirectionInstructionsPage> {
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
    // Speak the direction pronunciation
    await flutterTts.speak("الاتجاه في ال$meaning");
  }

  Future<void> speakInstructions() async {
    await flutterTts.speak(
      "سيكون لكل سؤال مؤقت 5 ثوانٍ للإجابة. انظر إلى شكل الاتجاه بعناية واختر الجملة الصحيحة. بعد كل سؤال، سيتم عرض الإجابة الصحيحة.",
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseFontSize = screenWidth < 360 ? 14 : 16;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              child: Center(
                child: Text(
                  "المستوى 2: الاتجاهات",
                  style: TextStyle(
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
                            const Text(
                              "معلومات عن التمرين",
                              style: TextStyle(
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timer, color: Color(0xFF7367F0)),
                                SizedBox(width: 8),
                                Flexible(child: Text("سيكون لكل سؤال مؤقت 5 ثوانٍ للإجابة.")),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.hearing, color: Color(0xFF7367F0)),
                                SizedBox(width: 8),
                                Flexible(child: Text("انظر إلى شكل الاتجاه بعناية واختر الجملة الصحيحة.")),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Color(0xFF7367F0)),
                                SizedBox(width: 8),
                                Flexible(child: Text("بعد كل سؤال، سيتم عرض الإجابة الصحيحة.")),
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
                                builder: (_) => const DirectionGamePage(totalQuestions: 10),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school, color: Colors.white),
                          label: const Text(
                            "ابدأ التمرين",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.only(right: 4, bottom: 10),
                        child: Text(
                          "الاتجاهات",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 20),
                        child: Text(
                          "اضغط على السهم لسماع الاتجاه",
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
                              // Second attempt: Allow user to listen again
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
      ),
    );
  }
}
