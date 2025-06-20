import 'package:flutter/material.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

class SignupCountryDropdown extends StatelessWidget {
  const SignupCountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hintText,
    this.isDarkMode = false,
  });

  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool isDarkMode;

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
    {'name': 'Libya', 'emoji': '🇱🇾'},
    {'name': 'Mauritania', 'emoji': '🇲🇷'},
    {'name': 'Somalia', 'emoji': '🇸🇴'},
    {'name': 'Djibouti', 'emoji': '🇩🇯'},
    {'name': 'Comoros', 'emoji': '🇰🇲'},
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
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hintText ?? S.of(context).signupinputfieldnationality,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: value == null
              ? Container(
            width: 48,
            alignment: Alignment.center,
            child: const Text(
              '🌍',
              style: TextStyle(fontSize: 22),
            ),
          ) : null,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            size: 24,
          ),
          filled: true,
          fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(249, 178, 136, 1),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.fromLTRB(
            isArabic() ? 8 : 16,
            16,
            isArabic() ? 50 : 50,
            16,
          ),
        ),
        icon: const SizedBox.shrink(), // Hide default icon since we're using suffixIcon
        dropdownColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: countries.map((country) {
          return DropdownMenuItem(
            value: country['name'],
            child: Container(
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
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        menuMaxHeight: 300,
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
      ),
    );
  }
}

// Alternative simplified version for even easier usage
class SimpleCountryDropdown extends StatelessWidget {
  const SimpleCountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.label,
    this.hintText,
  });

  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? label;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SignupCountryDropdown(
          value: value,
          onChanged: onChanged,
          validator: validator,
          hintText: hintText,
        ),
      ],
    );
  }
}