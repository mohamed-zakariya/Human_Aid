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
    {super.key,}
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

  bool get _isPasswordField {
    final title = widget.title;
    final passwordTitles = [
      S.current.signuptitlepassword,
      S.current.signuptitleconfirmpassword,
    ];
    return passwordTitles.contains(title);
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
            padding: EdgeInsets.fromLTRB(
              isArabic() ? 0 : 8,
              0,
              isArabic() ? 8 : 0,
              0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(
                  widget.colorbR, widget.colorbG, widget.colorbB, widget.opacityb),
            ),
            child: TextFormField(
              validator: widget.validation,
              controller: widget.controller,
              obscureText: _isPasswordField ? _obscureText : false,
              style: TextStyle(
                color: widget.makeBlack ? Colors.black : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: widget.text,
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey[500]),
                border: InputBorder.none,
                suffixIcon: _isPasswordField
                    ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
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


