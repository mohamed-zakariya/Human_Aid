import 'package:flutter/material.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

class SignupCountryDropdown extends StatelessWidget {
  const SignupCountryDropdown(
      this.text,
      this.title,
      this.colorbR,
      this.colorbG,
      this.colorbB,
      this.opacityb,
      this.colorlR,
      this.colorlG,
      this.colorlB,
      this.opacityl,
      this.makeBlack,
      this.titleBWhiteEn,
      this.value,
      this.onChanged,
      this.validation,
      {super.key}
      );

  final String text, title;
  final int colorbR, colorbG, colorbB, colorlR, colorlG, colorlB;
  final double opacityb, opacityl;
  final bool makeBlack, titleBWhiteEn;
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
    final primaryColor = Color.fromRGBO(colorbR, colorbG, colorbB, opacityb);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced title
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleBWhiteEn ? Colors.white : Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Enhanced dropdown container
          Container(
            width: 300,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primaryColor,
              border: Border.all(
                color: makeBlack
                    ? Colors.black.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: makeBlack ? Colors.white : const Color(0xFF2C2C2C),
              ),
              child: DropdownButtonFormField<String>(
                value: value,
                isExpanded: true,
                icon: Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: makeBlack ? Colors.black54 : Colors.white70,
                    size: 24,
                  ),
                ),
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country['name'],
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 20,
                            alignment: Alignment.center,
                            child: Text(
                              country['emoji']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country['name']!,
                              style: TextStyle(
                                color: makeBlack ? Colors.black87 : Colors.white70,
                                fontSize: 15,
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
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                    isArabic() ? 8 : 16,
                    12,
                    isArabic() ? 16 : 8,
                    12,
                  ),
                  hintText: text,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: makeBlack ? Colors.grey[500] : Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
                validator: validation,
                menuMaxHeight: 280,
                borderRadius: BorderRadius.circular(12),
                elevation: 8,
                style: TextStyle(
                  color: makeBlack ? Colors.black87 : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}