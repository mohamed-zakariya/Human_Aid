import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../widgets/language_toggle_icon.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_button.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const OnboardingScreen({super.key, required this.onLocaleChange});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> localizedData = [
      {
        'title': S.of(context).title1,
        'description': S.of(context).desc1,
        'buttonText': S.of(context).button1,
        'imagePath': 'assets/images/image1.png',
        'buttonColor': const Color.fromARGB(255, 238, 190, 198),
      },
      {
        'title': S.of(context).title2,
        'description': S.of(context).desc2,
        'buttonText': S.of(context).button2,
        'imagePath': 'assets/images/image2.png',
        'buttonColor': const Color.fromARGB(255, 168, 209, 209),
      },
      {
        'title': S.of(context).title3,
        'description': S.of(context).desc3,
        'buttonText': S.of(context).submitbutton,
        'imagePath': 'assets/images/image3.png',
        'buttonColor': const Color.fromARGB(255, 249, 178, 136),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageToggleIcon(onLocaleChange: widget.onLocaleChange),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: localizedData.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final Map<String, dynamic> data = localizedData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  data['imagePath'] as String,
                  height: 250,
                ),
                const SizedBox(height: 30),
                OnboardingIndicator(
                  currentPage: _currentPage,
                  pageCount: localizedData.length,
                  activeColor: data['buttonColor'] as Color,
                ),
                const SizedBox(height: 40),
                Text(
                  data['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['description'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const Spacer(),
                OnboardingButton(
                  text: data['buttonText'] as String,
                  onPressed: () {
                    if (index == localizedData.length - 1) {
                      Navigator.pushNamed(context, '/intro');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  backgroundColor: data['buttonColor'] as Color,
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
