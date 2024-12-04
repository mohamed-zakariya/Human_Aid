import 'package:flutter/material.dart';


class Level1NextButton extends StatelessWidget {
  final bool initialRecordDone;
  final VoidCallback onToggle;
  const Level1NextButton({super.key, required this.initialRecordDone, required this.onToggle});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: (){

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: initialRecordDone == true? Colors.red.shade200: Colors.grey.shade300, // Background color
        foregroundColor: Colors.white, // Text color
        shadowColor: const Color(0x33000000), // Shadow color
        elevation: 6, // Elevation for shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        padding: const EdgeInsets.all(5), // Padding inside the button
        minimumSize: Size(
          MediaQuery.of(context).size.width - 200,
          60, // Button size
        ),
      ),
      child: const Text(
        "التالي",
        style: TextStyle(
          fontSize: 35,
        ),
      ),
    );
  }
}
