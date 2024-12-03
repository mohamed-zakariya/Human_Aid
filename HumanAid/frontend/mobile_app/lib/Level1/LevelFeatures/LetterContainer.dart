import 'package:flutter/material.dart';
import 'LetterSplitter.dart';

class LetterContainer extends StatelessWidget {

  final String word;

  const LetterContainer({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: const[
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(
              0,
              6,
            ),
          )
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 10,
          children: word.split('').map((char) => LetterSplitter(
              letter: char,
              stringLength: word.length,
              screenWidth: MediaQuery.of(context).size.width)).toList()
          ,
        ),
      ),
    );
  }
}
