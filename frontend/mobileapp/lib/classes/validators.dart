import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/Services/check_exists.dart';
import 'package:mobileapp/generated/l10n.dart';

class Validators{

  static String? validateName(String? value){

    if(value == null || value.isEmpty){
      return  Intl.getCurrentLocale() == 'ar'? "يجب إدخال الاسم" : "Name must be Entered";
    }
    else if(value.length < 5){
      return Intl.getCurrentLocale() == 'ar'? "يجب أن يكون الاسم على الأقل 2 أحرف" : "Name must be at least 2  characters";
    }
    return null;
  }

  static String? validateUsername(String? value){

    if(value == null || value.isEmpty){
      return  Intl.getCurrentLocale() == 'ar'? "يجب إدخال اسم المستخدم" : "Username must be Entered";
    }
    else if(value.length < 3){
      return Intl.getCurrentLocale() == 'ar'? "يجب أن يكون اسم المستخدم على الأقل 3 أحرف" : "Username must be at least 3  characters";
    }
    return null;
  }
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'?  "يجب إدخال البريد الإلكتروني":"Email must be entered";
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
      return Intl.getCurrentLocale() == 'ar'? "يرجى إدخال بريد إلكتروني صحيح" : "Enter a valid email address";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return  Intl.getCurrentLocale() == 'ar'? "يجب إدخال كلمة المرور":"Password must be entered";
    } else if (value.length < 6) {
      return Intl.getCurrentLocale() == 'ar'?  "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل":"Password must be at least 8 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value, TextEditingController? controller) {
    if (value == null || value.isEmpty) {
      return Intl.getCurrentLocale() == 'ar'? "يجب تأكيد كلمة المرور":"Confirm password must be entered";
    } else if (value != controller?.text) {
      return Intl.getCurrentLocale() == 'ar'?  "كلمتا المرور غير متطابقتين":"Passwords do not match";
    }
    return null;
  }


}
