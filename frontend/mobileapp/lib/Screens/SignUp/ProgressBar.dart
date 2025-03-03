import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Progressbar extends StatelessWidget {
  const Progressbar(
    this.widthsize,
    this.heightsize,
    this.colorR,
    this.colorG,
    this.colorB,
    this.circularcheck,
    this.finishcheck, {
    super.key,
  });

  final double widthsize, heightsize;
  final int colorR, colorG, colorB;
  final bool circularcheck, finishcheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthsize,
      height: heightsize,
      decoration: BoxDecoration(
        color: Color.fromRGBO(colorR, colorG, colorB, 1),
        borderRadius: circularcheck ? BorderRadius.circular(30) : BorderRadius.circular(0),
      ),
      child:  !finishcheck? const Text(""): const Center(
          child: 
            FaIcon(
              FontAwesomeIcons.check,
              size: 32.0, // Actual icon size
              color: Colors.white, // Foreground color
            ),
          ),
    );
  }
}
