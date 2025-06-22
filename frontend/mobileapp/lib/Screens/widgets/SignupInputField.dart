import 'package:flutter/material.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

class Signupinputfield extends StatefulWidget {
  const Signupinputfield(
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
      this.controller,
      this.validation,
      {super.key}
      );

  final String text, title;
  final int colorbR, colorbG, colorbB, colorlR, colorlG, colorlB;
  final double opacityb, opacityl;
  final bool makeBlack, titleBWhiteEn;
  final TextEditingController controller;
  final String? Function(String?)? validation;

  @override
  State<Signupinputfield> createState() => _SignupinputfieldState();
}

class _SignupinputfieldState extends State<Signupinputfield> {
  bool _obscureText = true;
  bool _isFocused = false;

  bool get _isPasswordField {
    final title = widget.title;
    final passwordTitles = [
      S.current.signuptitlepassword,
      S.current.signuptitleconfirmpassword,
    ];
    return passwordTitles.contains(title);
  }

  // Get appropriate prefix icon based on field type
  IconData? get _getPrefixIcon {
    final title = widget.title;

    if (title == S.current.signuptitlename) {
      return Icons.person_outline;
    } else if (title == S.current.signuptitlephonenumber) {
      return Icons.phone_outlined;
    } else if (title == S.current.signuptitlenationality) {
      return Icons.flag_outlined;
    } else if (_isPasswordField) {
      return Icons.lock_outline;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromRGBO(
      widget.colorbR,
      widget.colorbG,
      widget.colorbB,
      widget.opacityb,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Title
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.titleBWhiteEn ? Colors.white : Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Enhanced Input Field
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: _isPasswordField ? _obscureText : false,
              style: TextStyle(
                color: widget.makeBlack ? Colors.black87 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              validator: widget.validation,
              decoration: InputDecoration(
                hintText: widget.text,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: widget.makeBlack ? Colors.grey[500] : Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                // Add prefix icon
                prefixIcon: _getPrefixIcon != null
                    ? Icon(
                  _getPrefixIcon,
                  color: const Color.fromRGBO(108, 99, 255, 1),
                  size: 22,
                )
                    : null,
                // Add filled background like the enhanced email field
                filled: true,
                fillColor: primaryColor,
                contentPadding: EdgeInsets.fromLTRB(
                  _getPrefixIcon != null ? 16 : (isArabic() ? 16 : 20),
                  16,
                  isArabic() ? 20 : 16,
                  16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.3),
                      width: 1.5
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(108, 99, 255, 1),
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
                suffixIcon: _isPasswordField
                    ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}