import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class RecordSystem extends StatelessWidget {

  final double screenWidth;
  final bool recordFlag;
  final VoidCallback  onToggle;
  const RecordSystem({super.key, required this.screenWidth,
  required this.recordFlag, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 15, 0, 20),
      child: Opacity(
        opacity: 1,
        child: ElevatedButton(
          onPressed:onToggle,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(), // Makes the button circular
            padding: EdgeInsets.fromLTRB(0, screenWidth/10, 0, 0), // Removes padding for a precise size
            // backgroundColor: Colors.transparent,

            // Background color
            elevation: 15, // Adds elevation
          ),
          child: Column(
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Container(
                  width: 80,
                  height: MediaQuery.of(context).size.height>0 ? 80: 0,
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,

                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Icon(
                      Icons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Opacity(
                opacity: 0.5,
                child: Text("", style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSans",
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
