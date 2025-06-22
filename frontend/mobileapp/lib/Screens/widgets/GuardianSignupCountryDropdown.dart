import 'package:flutter/material.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

class Guardiansignupcountrydropdown extends StatelessWidget {
  const Guardiansignupcountrydropdown(
      this.text,
      this.title,
      this.value,
      this.onChanged,
      this.validation,
      {super.key}
      );

  final String text, title;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validation;

  // Enhanced list of countries with emojis
  static const List<Map<String, String>> countries = [
    {'name': 'Egypt', 'emoji': '🇪🇬'},
    {'name': 'Saudi Arabia', 'emoji': '🇸🇦'},
    {'name': 'United Arab Emirates', 'emoji': '🇦🇪'},
    {'name': 'Jordan', 'emoji': '🇯🇴'},
    {'name': 'Lebanon', 'emoji': '🇱🇧'},
    {'name': 'Morocco', 'emoji': '🇲🇦'},
    {'name': 'Tunisia', 'emoji': '🇹🇳'},
    {'name': 'Algeria', 'emoji': '🇩🇿'},
    {'name': 'Sudan', 'emoji': '🇸🇩'},
    {'name': 'Iraq', 'emoji': '🇮🇶'},
    {'name': 'Syria', 'emoji': '🇸🇾'},
    {'name': 'Yemen', 'emoji': '🇾🇪'},
    {'name': 'Palestine', 'emoji': '🇵🇸'},
    {'name': 'Qatar', 'emoji': '🇶🇦'},
    {'name': 'Bahrain', 'emoji': '🇧🇭'},
    {'name': 'Kuwait', 'emoji': '🇰🇼'},
    {'name': 'Oman', 'emoji': '🇴🇲'},
  ];

  String? _getCountryEmoji(String? countryName) {
    if (countryName == null) return null;
    try {
      final country = countries.firstWhere(
            (country) => country['name'] == countryName,
        orElse: () => {'name': '', 'emoji': '🌍'},
      );
      return country['emoji'];
    } catch (e) {
      return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            validator: validation,
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color.fromRGBO(108, 99, 255, 1),
            ),
            decoration: InputDecoration(
              hintText: text,
              prefixIcon: value == null
                  ? Container(
                width: 48,
                alignment: Alignment.center,
                child: const Text(
                  '🌍',
                  style: TextStyle(fontSize: 20),
                ),
              ) : null,
              filled: true,
              fillColor: const Color.fromRGBO(108, 99, 255, 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromRGBO(108, 99, 255, 1), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: countries.map((country) {
              return DropdownMenuItem(
                value: country['name'],
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 24,
                      alignment: Alignment.center,
                      child: Text(
                        country['emoji']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country['name']!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }
}