import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobileapp/models/letter.dart'; // lowercase 'models'
import '../../../../Services/tts_service.dart';
import '../../../../Services/letters_service.dart'; // Import your LettersService

class LetterLevel1 extends StatefulWidget {
  const LetterLevel1({super.key});

  @override
  State<LetterLevel1> createState() => _LetterLevel1State();
}

class _LetterLevel1State extends State<LetterLevel1> {
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

  final AudioPlayer _audioPlayer = AudioPlayer();
  final TTSService _ttsService = TTSService();

  List<Letter> letters = [];
  bool isLoading = true;

  Map<String, Color> groupColorMap = {};

  @override
  void initState() {
    super.initState();
    _fetchLetters();
    _ttsService.initialize(language: 'ar-SA'); // Arabic (Saudi Arabia)
  }

  Future<void> _fetchLetters() async {
    setState(() {
      isLoading = true;
    });

    final fetchedLetters = await LettersService.getLettersForLevel1();

    if (fetchedLetters != null) {
      // Group letters by their 'group' property and assign colors based on their order
      groupColorMap.clear();
      for (var i = 0; i < fetchedLetters.length; i++) {
        final letter = fetchedLetters[i];
        if (!groupColorMap.containsKey(letter.group)) {
          // Assign a new color from the colors list
          groupColorMap[letter.group] = colors[i % colors.length];
        }
      }

      setState(() {
        letters = fetchedLetters;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error fetching letters");
    }
  }


  Future<void> playLetterSound(String letter) async {
    try {
      await _ttsService.speak(letter);
    } catch (e) {
      print('Error speaking letter: $e');
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 250,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.6),
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onPressed: () {
                    playLetterSound(letter);
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text('استمع'),
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
        title: const Text("المستوي الأول"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: letters.length,
            itemBuilder: (context, index, realIndex) {
              final letter = letters[index];
              final groupColor = groupColorMap[letter.group] ?? Colors.grey; // Default to grey if no color found
              return buildLetterCard(
                letter: letter.letter,
                color: groupColor,
                index: index,
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.65,
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
          const SizedBox(height: 20),
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
              const SizedBox(width: 32),
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
