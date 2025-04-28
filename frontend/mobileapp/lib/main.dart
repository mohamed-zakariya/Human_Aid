import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobileapp/Screens/IntroductoryScreen/intro_screen.dart';
import 'package:mobileapp/Screens/IntroductoryScreen/onboarding_screen.dart';
import 'package:mobileapp/Screens/LearnerScreen/LearnerMain.dart';
import 'package:mobileapp/Screens/LearnerScreen/learner_home_screen.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceTest/test_selector.dart';
import 'package:mobileapp/Screens/ParentScreen/ParentHome.dart';
import 'package:mobileapp/Screens/SignUp/ContinueSignup.dart';
import 'package:mobileapp/Screens/SignUp/signupadult.dart';
import 'package:mobileapp/Screens/SignUp/signupmain.dart';
import 'package:mobileapp/Screens/scentence_pronunciation_screen.dart';
import 'package:mobileapp/Screens/word_pronunciation_screen.dart';
import 'package:mobileapp/Services/learner_home_service.dart';
import 'package:mobileapp/generated/l10n.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/parent.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceTest/quizapp.dart';

import 'Screens/Login/change_password_screen.dart';
import 'Screens/Login/forgot_password_screen.dart';
import 'Screens/Login/login_screen_gaurdian.dart';
import 'Screens/Login/login_screen_user.dart';
import 'Screens/Login/otp_verification_screen.dart';
import 'Screens/ParentScreen/ParentMain.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp ({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color.fromRGBO(0, 0, 0, 1),
      locale: _locale,
       localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
        supportedLocales: S.delegate.supportedLocales,
        initialRoute: '/quiz',
        routes: {
          '/intro': (context) => IntroScreen(onLocaleChange: _setLocale),
          '/quiz': (context) => TestSelectorWidget(userProgress: 0.3),
          '/login_user': (context) => LoginScreenUser(onLocaleChange: _setLocale),
          '/login_gaurdian': (context) => LoginScreenGaurdian(onLocaleChange: _setLocale),
          '/forgot-password': (context) => ForgotPasswordPage(onLocaleChange: _setLocale),
          '/otp-verification': (context) => OTPVerificationScreen(onLocaleChange: _setLocale),
          '/change-password': (context) => ChangePasswordScreen(onLocaleChange: _setLocale),
          '/wordPronunciation': (context) => WordPronunciationScreen(onLocaleChange: _setLocale),
          '/ScentencePronunciationScreen': (context) => SentencePronunciationScreen(onLocaleChange: _setLocale),
          '/signupAdult': (context) => const Signupadult(),
          '/signup1': (context) => const Signupmain(),
          '/signup2': (context) {
            final Parent parent = ModalRoute.of(context)!.settings.arguments as Parent;
            return Continuesignup(parent: parent);
          },
          '/parentHome': (context) {
            final Parent parent = ModalRoute.of(context)!.settings.arguments as Parent;
            return ParentMain(parent: parent, onLocaleChange: _setLocale,);
          },
          // '/learnerMain': (context) {
          //   final Learner learner = ModalRoute.of(context)!.settings.arguments as Learner;
          //   return LearnerMain(learner: learner, onLocaleChange: _setLocale,);
          // },
          '/Learner-Home': (context) {
            final learner = ModalRoute.of(context)!.settings.arguments as Learner;
            return LearnerHomeScreen(
              onLocaleChange: _setLocale,
              learner: learner,
            );
          },

      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Unknown Route: ${settings.name}'),
          ),
        ),
      ),
      home: OnboardingScreen(onLocaleChange: _setLocale),
    );
  }
}

// class HomeView extends StatelessWidget {
//   const HomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Login();
//   }
// }


