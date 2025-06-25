import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Services/auth_service.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';


class SignupInputFieldEmail extends StatefulWidget {
  const SignupInputFieldEmail(
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
      this.flag,
      {super.key,}
      );

  final String text, title;
  final int colorbR, colorbG, colorbB, colorlR, colorlG, colorlB;
  final double opacityb, opacityl;
  final bool makeBlack, titleBWhiteEn;
  final TextEditingController controller;
  final bool? flag;

  @override
  _SignupInputFieldEmailState createState() => _SignupInputFieldEmailState();
}

class _SignupInputFieldEmailState extends State<SignupInputFieldEmail> {
  String? _emailError;
  final GlobalKey<FormFieldState<String>> _emailFieldKey = GlobalKey<FormFieldState<String>>();

  // Synchronous validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب إدخال البريد الإلكتروني"
          : "Email must be entered";
    } else if (value.length < 3) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب أن يكون البريد الإلكتروني على الأقل 3 أحرف"
          : "Email must be at least 3 characters";
    }
    return _emailError; // This will be set asynchronously
  }

  // Asynchronous check for existing Email
  Future<void> _checkEmailExists(String value) async {
    bool exists = widget.flag == true
        ? await AuthService.emailParentCheck(value)
        : await AuthService.emailLearnerCheck(value);

    setState(() {
      _emailError = exists ? S.of(context).emailExist : null;
      // _emailFieldKey.currentState?.validate(); // Trigger re-validation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              color: widget.titleBWhiteEn ? Colors.white : Colors.black,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 55,
            padding: EdgeInsets.fromLTRB(isArabic() ? 0 : 8, 0, isArabic() ? 8 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(widget.colorbR, widget.colorbG, widget.colorbB, widget.opacityb),
            ),
            child: TextFormField(
              key: _emailFieldKey, // Assign key to trigger revalidation
              controller: widget.controller,
              validator: _validateEmail,
              onChanged: (value) {
                _checkEmailExists(value); // Asynchronous check
              },
              style: TextStyle(color: widget.makeBlack ? Colors.black : Colors.white),
              decoration: InputDecoration(
                hintText: widget.text,
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey[500]),
                border: InputBorder.none,
              ),
              obscureText: (widget.title == S.of(context).signuptitlepassword ||
                  widget.title == S.of(context).signuptitleconfirmpassword),
            ),
          ),
        ],
      ),
    );
  }
}
