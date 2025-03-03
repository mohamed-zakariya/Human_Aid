import 'package:flutter/material.dart';
import 'package:mobileapp/classes/validators.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/global/fns.dart';

class Signupinputfield extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontSize: 18,
            color: titleBWhiteEn? Colors.white: Colors.black
          ),),
          Container(
            width: 300,
            height: 55,
            padding: EdgeInsets.fromLTRB(
              isArabic()? 0:8,
              0,
              isArabic()? 8:0,
              0
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(colorbR, colorbG, colorbB, opacityb),
            ),
            child: TextFormField(
              validator: validation,
              controller: controller,
              style: TextStyle(
                color: makeBlack? Colors.black: Colors.white
              ),
              decoration: InputDecoration(
                hintText: text,
                hintStyle:  TextStyle(
                  fontSize: 15,
                  color: Colors.grey[500]
                ),
                border: InputBorder.none,
              ),
              obscureText: (title == S.of(context).signuptitlepassword || title ==  S.of(context).signuptitleconfirmpassword)? true:false,
            ),
          ),
        ],
      ),
    );
  }
}

