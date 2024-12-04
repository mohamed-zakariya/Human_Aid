import 'package:flutter/material.dart';


class Level1NextButton extends StatelessWidget {
  const Level1NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      alignment: const Alignment(0, 0),
      width: MediaQuery.of(context).size.width - 200,
      height: MediaQuery.of(context).size.height > 0 ? 60 : 0,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const[
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(
              0,
              6,
            ),
          )
        ],// Adjust the radius as needed
      ),
      child: const Text(
        "التالي",
        style: TextStyle(
          fontSize: 35,
          color: Colors.brown,
        ),
      ),
    );
  }
}
