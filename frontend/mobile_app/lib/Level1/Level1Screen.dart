import 'package:flutter/material.dart';

import 'LevelFeatures/DisplayedText.dart';
import 'LevelFeatures/LetterContainer.dart';
import 'LevelFeatures/Level1Navbar.dart';
import 'LevelFeatures/Level1NextButton.dart';
import 'LevelFeatures/RecordSystem.dart';
import 'LevelFeatures/TextGenerated.dart';

class Level1screen extends StatefulWidget {
  const Level1screen({super.key});

  @override
  State<Level1screen> createState() => _Level1screenState();
}

class _Level1screenState extends State<Level1screen> {

  bool initialRecordDone = false;
  // const widthScreen = MediaQuery.of(context).size.width;
  void toggleRecordDone() {
    setState(() {
      initialRecordDone = true;
      print(initialRecordDone);
    });
  }

  @override
  Widget build(BuildContext context) {

    const String word = "التفاحة"; // Replace with any word


    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade100,
          title: const Align(
            alignment: AlignmentDirectional(0, 0.5),
            child: Level1Navbar(),
          ),
        ),
        body:  Container(
          margin: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              children: [
                // Rectangle Design for the displayed text with the timer and the voice
                const DisplayedText(word: word),
                const LetterContainer(word: word),
                const TextGenerated(),
                RecordSystem(screenWidth: MediaQuery.of(context).size.width, recordFlag: initialRecordDone, onToggle: toggleRecordDone,),
                Level1NextButton(initialRecordDone: initialRecordDone, onToggle: toggleRecordDone)
              ],
            ),
          ),
        ),
    );
  }
}
