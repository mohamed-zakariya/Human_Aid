import 'package:flutter/material.dart';

class LanguageToggleIcon extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageToggleIcon({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () {
        final currentLocale = Localizations.localeOf(context);
        final newLocale =
        currentLocale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
        onLocaleChange(newLocale);
      },
    );
  }
}
