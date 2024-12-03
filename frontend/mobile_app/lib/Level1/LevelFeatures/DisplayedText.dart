import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DisplayedText extends StatelessWidget {
  final String word;
  const DisplayedText({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFFADADD),
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
      child: Column(
        children: [
          // volume & image & timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0X4D39D2C0),
                ),
                child: IconButton(
                  onPressed: () {print("hello");},
                  icon: const FaIcon(
                    FontAwesomeIcons.volumeHigh,
                    size: 20,
                  ),

                ),
              ),
              ClipRRect(
                child: Image.asset(
                  'assets/images/apple.webp',
                  width: 90,
                  height: 90,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x4C4B39EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 16, 8, 16),
                  child: Text(
                    '00:00',
                    style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.black,
                        letterSpacing: 0.0,
                        fontSize: 15
                    ),
                  ),
                ),
              )
            ],
          ),
          // Text Displayed
          Container(
            margin: const EdgeInsets.all(10),
            alignment: const AlignmentDirectional(0, 0),
            width: MediaQuery.of(context).size.width,
            child: Text(word,style: const TextStyle(
                fontSize: 55,
                color: Color(0xFF6D5144),
                fontWeight: FontWeight.w600,
                fontFamily: "OpenSans"
            ),),
          )
        ],
      ),
    );
  }
}
