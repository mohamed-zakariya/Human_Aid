import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

import '../../Services/check_exists.dart';

class SignupInputFieldUsername extends StatefulWidget {
  const SignupInputFieldUsername(
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
      {super.key,}
      );

  final String text, title;
  final int colorbR, colorbG, colorbB, colorlR, colorlG, colorlB;
  final double opacityb, opacityl;
  final bool makeBlack, titleBWhiteEn;
  final TextEditingController controller;

  @override
  _SignupInputFieldUsernameState createState() => _SignupInputFieldUsernameState();
}

class _SignupInputFieldUsernameState extends State<SignupInputFieldUsername> {
  String? _usernameError;

  // Synchronous validation
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب إدخال اسم المستخدم"
          : "Username must be entered";
    } else if (value.length < 3) {
      return Intl.getCurrentLocale() == 'ar'
          ? "يجب أن يكون اسم المستخدم على الأقل 3 أحرف"
          : "Username must be at least 3 characters";
    }
    return _usernameError; // This will be set asynchronously
  }

  // Asynchronous check for existing username
  Future<void> _checkUsernameExists(String value) async {
    bool exists = await CheckExists.usernameLearnerCheck(value);
    print("existsss $exists");
    if (exists) {
      setState(() {
        _usernameError = S.of(context).usernameExist;
        print(_usernameError);
      });
    } else {
      setState(() {
        _usernameError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 300,
            height: 55,
            padding: EdgeInsets.fromLTRB(isArabic() ? 0 : 8, 0, isArabic() ? 8 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(widget.colorbR, widget.colorbG, widget.colorbB, widget.opacityb),
            ),
            child: TextFormField(
              controller: widget.controller,
              validator: _validateUsername,
              onChanged: (value) {
                _checkUsernameExists(value);
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
