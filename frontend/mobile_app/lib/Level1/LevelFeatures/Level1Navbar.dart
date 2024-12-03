import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Level1Navbar extends StatelessWidget {
  const Level1Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("     "),
        const Text("المستوي الاول", style: TextStyle(
          fontSize: 40,
          fontFamily: "OpenSans",
          fontWeight: FontWeight.w800,
          color: Colors.black54,
        ),),
        IconButton(onPressed: () {print("Hello");},
            icon: const FaIcon(
              FontAwesomeIcons.circleQuestion,
              color: Colors.white,
              size: 30,
            ))
      ],
    );
  }
}
