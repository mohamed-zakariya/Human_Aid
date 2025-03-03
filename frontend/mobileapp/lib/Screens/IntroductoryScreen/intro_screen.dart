import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../widgets/language_toggle_icon.dart';

class IntroScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const IntroScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final textAlign = Localizations.localeOf(context).languageCode == 'ar'
        ? TextAlign.right
        : TextAlign.left;

    final crossAxisAlignment = Localizations.localeOf(context).languageCode == 'ar'
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageToggleIcon(onLocaleChange: onLocaleChange),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Center(
                    child: Text(
                      S.of(context).introTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: textAlign,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  _buildRegistrationOption(
                    image: 'assets/images/guardian.png',
                    title: S.of(context).guardianTitle,
                    description: S.of(context).guardianDescription,
                    maxHeight: constraints.maxHeight * 0.33,
                    crossAxisAlignment: crossAxisAlignment,
                    textAlign: textAlign,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  _buildRegistrationOption(
                    image: 'assets/images/user.png',
                    title: S.of(context).userTitle,
                    description: S.of(context).userDescription,
                    maxHeight: constraints.maxHeight * 0.3,
                    crossAxisAlignment: crossAxisAlignment,
                    textAlign: textAlign,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {Navigator.pushNamed(context, '/login_gaurdian');},
                          style: _buttonStyle(
                            backgroundColor: const Color.fromARGB(255, 238, 190, 198),
                          ),
                          child: Text(S.of(context).guardianButton),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {Navigator.pushNamed(context, '/login_user');},
                          style: _buttonStyle(
                            backgroundColor: const Color.fromARGB(255, 238, 190, 198),
                          ),
                          child: Text(S.of(context).userButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle({Color backgroundColor = const Color.fromARGB(0,0,0,0)}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildRegistrationOption({
    required String image,
    required String title,
    required String description,
    required double maxHeight,
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
  }) {
    return SizedBox(
      height: maxHeight,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Card(
                  color: const Color.fromARGB(255, 168, 209, 209), // Updated color of the card
                  elevation: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: crossAxisAlignment,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: textAlign,
                        ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            description,
                            textAlign: textAlign,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
