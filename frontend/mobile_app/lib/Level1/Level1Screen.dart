import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_app/Level1/LevelFeatures/Level1Navbar.dart';
import 'package:mobile_app/Level1/LevelFeatures/Level1NextButton.dart';
import 'LevelFeatures/DisplayedText.dart';
import 'LevelFeatures/LetterContainer.dart';
import 'LevelFeatures/RecordSystem.dart';
import 'LevelFeatures/TextGenerated.dart';

class Level1screen extends StatelessWidget {
  const Level1screen({super.key});

  @override
  Widget build(BuildContext context) {

    const String word = "التفاحة"; // Replace with any word
    // const widthScreen = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
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
                RecordSystem(screenWidth: MediaQuery.of(context).size.width),
                const Level1NextButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
