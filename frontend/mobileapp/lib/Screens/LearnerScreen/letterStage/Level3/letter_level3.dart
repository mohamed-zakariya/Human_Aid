import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'letter_forms.dart';
import '../../../../Services/tts_service.dart';

class LetterLevel3 extends StatefulWidget {
  const LetterLevel3({super.key});

  @override
  State<LetterLevel3> createState() => _LetterLevel3State();
}

class _LetterLevel3State extends State<LetterLevel3> {

  final List<String> arabicLetters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د',
    'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط',
    'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م',
    'ن', 'ه', 'و', 'ي'
  ];





  final List<Color> colors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.brown, Colors.pink,
    Colors.indigo, Colors.amber, Colors.deepOrange, Colors.cyan,
    Colors.deepPurple, Colors.lime, Colors.lightBlue, Colors.lightGreen,
    Colors.yellow, Colors.blueGrey, Colors.redAccent, Colors.greenAccent,
    Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.brown,
    Colors.pinkAccent, Colors.indigoAccent, Colors.amberAccent, Colors.cyanAccent,
  ];

  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;



  Widget buildLetterCard({
    required String letter,
    required Color color,
    required int index,
  }) {


    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildFormRow('منفصل', letterForms[letter]?['منفصل'] ?? []),
                      const SizedBox(height: 5),
                      buildFormRow('متصل', letterForms[letter]?['متصل'] ?? []),
                      const SizedBox(height: 5),
                      buildFormRow('نهائي', letterForms[letter]?['نهائي'] ?? [])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: const Text("المستوي التالت"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 15),
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: arabicLetters.length,
            itemBuilder: (context, index, realIndex) {
              return buildLetterCard(
                letter: arabicLetters[index],
                color: colors[index % colors.length],
                index: index,
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.7
                  : MediaQuery.of(context).size.height * 0.85,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlay: false,
              viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
          // const SizedBox(height: 20),
          // Arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              // const SizedBox(width: 32),
              IconButton(
                onPressed: () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


Widget buildFormRow(String formName, List<Map<String, String>> forms) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = MediaQuery.of(context).size.width;
      double fontSizeLarge = screenWidth * 0.1; // approx 10% of width
      double fontSizeExample = screenWidth * 0.05;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formName,
            style: TextStyle(
              fontSize: fontSizeExample,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ...forms.map((formMap) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formMap['form'] ?? '',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Center(
                  child: Text(
                    'مثال: ${formMap['example'] ?? ''}',
                    style: TextStyle(
                      fontSize: fontSizeExample,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      );
    },
  );
}

