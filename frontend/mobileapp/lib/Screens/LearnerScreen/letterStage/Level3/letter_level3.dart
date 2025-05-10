import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../Services/tts_service.dart';
import '../letter_forms.dart';

class LetterLevel3 extends StatefulWidget {
  const LetterLevel3({super.key});

  @override
  State<LetterLevel3> createState() => _LetterLevel3State();
}

class _LetterLevel3State extends State<LetterLevel3> {


  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المستوي التالت"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // const SizedBox(height: 15),
          Expanded(
            child: CarouselSlider.builder(
              carouselController: _controller,
              itemCount: arabicLetters.length,
              itemBuilder: (context, index, realIndex) {
                return buildLetterContent(
                  letter: arabicLetters[index],
                  color: colors[index % colors.length],
                );
              },
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 30), // change slide every 30 seconds
                autoPlayAnimationDuration: Duration(milliseconds: 800), // transition animation
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                viewportFraction: 0.85,
                height: MediaQuery.of(context).size.height * 0.98,
                // enlargeCenterPage: true,
                // enableInfiniteScroll: false,
                // autoPlay: false,
                // viewportFraction: 0.85,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildLetterContent({
    required String letter,
    required Color color,
  }) {
    final forms = letterForms2[letter] ?? [];
    final random = Random();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Text(
              letter,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: forms.map<Widget>((formData) {
                return buildExampleCard(
                  formData['label'], // dynamic label
                  {
                    'form': formData['form'],
                    'example': formData['example'],
                    'image': formData['image'],
                  },
                  colors[random.nextInt(colors.length)].withOpacity(0.2),
                );
              }).toList(),
            ),

          ],
        ),
      ),
    );
  }


  Widget buildExampleCard(String label, Map<String, String> data, Color backgroundColor) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSize = screenWidth - 10;

    return Container(
      width: cardSize,
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['form'] ?? '',
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (data['image'] != null && data['image']!.isNotEmpty)
              Image.asset(
                data['image']!,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 12),
            Text(
              data['example'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
