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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            Localizations.localeOf(context).languageCode == 'en'
                ? "Level 3"
                : "المستوي التالت"
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                autoPlayInterval: const Duration(seconds: 30),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                viewportFraction: isTablet ? 0.7 : 0.85,
                height: screenSize.height * (isLandscape ? 0.85 : 0.92),
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
          _buildNavigationControls(screenSize),
          SizedBox(height: screenSize.height * 0.01),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(Size screenSize) {
    final iconSize = screenSize.width * 0.06;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: iconSize.clamp(20.0, 30.0),
            ),
          ),
          SizedBox(width: screenSize.width * 0.05),
          IconButton(
            onPressed: () {
              _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: iconSize.clamp(20.0, 30.0),
            ),
          ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    // Responsive font size for the main letter
    final letterFontSize = _getResponsiveFontSize(
        screenSize,
        baseSize: 100,
        minSize: 60,
        maxSize: 140
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.04,
          vertical: screenSize.height * 0.02,
        ),
        child: Column(
          children: [
            Text(
              letter,
              style: TextStyle(
                fontSize: letterFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            _buildFormsLayout(forms, random, screenSize, isTablet, isLandscape),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsLayout(List forms, Random random, Size screenSize, bool isTablet, bool isLandscape) {
    if (isLandscape && isTablet) {
      // Grid layout for landscape tablets
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: screenSize.width * 0.03,
          mainAxisSpacing: screenSize.height * 0.02,
          childAspectRatio: 1.2,
        ),
        itemCount: forms.length,
        itemBuilder: (context, index) {
          return buildExampleCard(
            forms[index]['label'],
            {
              'form': forms[index]['form'],
              'example': forms[index]['example'],
              'image': forms[index]['image'],
            },
            colors[random.nextInt(colors.length)].withOpacity(0.2),
          );
        },
      );
    } else {
      // Wrap layout for other cases
      return Wrap(
        spacing: screenSize.width * 0.03,
        runSpacing: screenSize.height * 0.02,
        alignment: WrapAlignment.center,
        children: forms.map<Widget>((formData) {
          return buildExampleCard(
            formData['label'],
            {
              'form': formData['form'],
              'example': formData['example'],
              'image': formData['image'],
            },
            colors[random.nextInt(colors.length)].withOpacity(0.2),
          );
        }).toList(),
      );
    }
  }

  Widget buildExampleCard(String label, Map<String, String> data, Color backgroundColor) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    // Responsive card dimensions
    double cardWidth;
    double cardHeight;

    if (isLandscape && isTablet) {
      // Landscape tablet - smaller cards in grid
      cardWidth = (screenSize.width - 80) / 2;
      cardHeight = screenSize.height * 0.45;
    } else if (isTablet) {
      // Portrait tablet
      cardWidth = screenSize.width * 0.85;
      cardHeight = screenSize.height * 0.35;
    } else {
      // Phone
      cardWidth = screenSize.width * 0.9;
      cardHeight = screenSize.height * (isLandscape ? 0.6 : 0.4);
    }

    // Responsive font sizes
    final formFontSize = _getResponsiveFontSize(screenSize, baseSize: 50, minSize: 35, maxSize: 65);
    final exampleFontSize = _getResponsiveFontSize(screenSize, baseSize: 40, minSize: 28, maxSize: 50);

    // Responsive image size
    final imageSize = _getResponsiveImageSize(screenSize, cardHeight);

    // Responsive padding
    final cardPadding = screenSize.width * 0.035;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(cardPadding),
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.01,
        vertical: screenSize.height * 0.005,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(screenSize.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: screenSize.width * 0.015,
            offset: Offset(screenSize.width * 0.005, screenSize.width * 0.005),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data['form'] ?? '',
                  style: TextStyle(
                    fontSize: formFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: cardHeight * 0.03),
            if (data['image'] != null && data['image']!.isNotEmpty)
              Flexible(
                flex: 3,
                child: Image.asset(
                  data['image']!,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ),
            SizedBox(height: cardHeight * 0.03),
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data['example'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: exampleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getResponsiveFontSize(Size screenSize, {required double baseSize, required double minSize, required double maxSize}) {
    final scaleFactor = (screenSize.width / 375).clamp(0.8, 2.0); // 375 is iPhone standard width
    final fontSize = baseSize * scaleFactor;
    return fontSize.clamp(minSize, maxSize);
  }

  double _getResponsiveImageSize(Size screenSize, double cardHeight) {
    final baseSize = cardHeight * 0.4;
    final minSize = 80.0;
    final maxSize = 200.0;
    return baseSize.clamp(minSize, maxSize);
  }
}