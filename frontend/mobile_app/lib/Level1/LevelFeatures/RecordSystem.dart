import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class RecordSystem extends StatelessWidget {

  final double screenWidth;

  const RecordSystem({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      child: Opacity(
        opacity: 1,
        child: ElevatedButton(
          onPressed: () {
            print("Container clicked!");
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(), // Makes the button circular
            padding: EdgeInsets.fromLTRB(0, screenWidth/10, 0, 0), // Removes padding for a precise size
            backgroundColor: const Color(0xFFFADADD),
            // Background color
            elevation: 5, // Adds elevation
          ),
          child: Column(
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Container(
                  width: 80,
                  height: MediaQuery.of(context).size.height>0 ? 80: 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF316BBE),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const Opacity(
                opacity: 0.5,
                child: Text("اضغط للتجيل", style: TextStyle(
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
