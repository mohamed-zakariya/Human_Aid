import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Screens/ParentScreen/LearnerData.dart';
import '../models/learner.dart';
import '../models/overall_progress.dart';


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

Route createRouteLearnerData(Learner learner, [UserExerciseProgress? userProgress]) { // ✅ userProgress is now optional
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => userProgress != null
        ? Learnerdata(learner: learner, progress: userProgress)
        : Learnerdata(learner: learner), // ✅ Don't pass progress if it's null
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
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


Route createRouteParentLearnerProgress(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
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
