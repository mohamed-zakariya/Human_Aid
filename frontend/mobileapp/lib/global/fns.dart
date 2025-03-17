import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Screens/ParentScreen/LearnerData.dart';


bool isArabic(){

  return Intl.getCurrentLocale() == 'ar';
}

int calculateAge(String birthdate) {
  DateTime birthDate = DateTime.parse(birthdate);
  DateTime today = DateTime.now();

  int age = today.year - birthDate.year;

  // Adjust if the birthday hasn't occurred yet this year
  if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}

Route createRouteLearnerData(learner) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Learnerdata(learner: learner),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start from right
      const end = Offset.zero;
      const curve = Curves.easeInOut; // Smooth animation

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Route createRouteParentHome(Widget Function() screenBuilder) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screenBuilder(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

