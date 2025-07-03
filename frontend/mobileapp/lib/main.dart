import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobileapp/Screens/IntroductoryScreen/intro_screen.dart';
import 'package:mobileapp/Screens/IntroductoryScreen/onboarding_screen.dart';
import 'package:mobileapp/Screens/LearnerScreen/LearnerMain.dart';
import 'package:mobileapp/Screens/LearnerScreen/learner_home_screen.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/Level2/letter_level2.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/Level2/letter_level2_game.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/Level2/letter_level2_game_2.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/Level3/letter_level3.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/Level3/letter_level3_game.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/level1/ArabicLetterTracingExercise.dart';
import 'package:mobileapp/Screens/LearnerScreen/letterStage/level1/letter_level1.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceStage/CombineGameBetween3Levels/sentence_ordered_by_sound.dart';
import 'package:mobileapp/Screens/LearnerScreen/sentenceTest/test_selector.dart';
import 'package:mobileapp/Screens/LearnerScreen/storyStage/Level1/StoryGeneratorForm.dart';
import 'package:mobileapp/Screens/LearnerScreen/wordStage/Level1/game1/screens/spelling_game_screen.dart';
import 'package:mobileapp/Screens/LearnerScreen/wordStage/Level2/first_game/direction_level1_instruction.dart';
import 'package:mobileapp/Screens/LearnerScreen/wordStage/Level2/fourth_game/arrow_detection_game.dart';
import 'package:mobileapp/Screens/LearnerScreen/wordStage/Level2/second_game/direction_game2_page.dart';
import 'package:mobileapp/Screens/LearnerScreen/wordStage/Level2/second_game/direction_level2_instruction.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/LearnerScreen/storyStage/Level2/story_summarize.dart';
import 'Screens/LearnerScreen/wordStage/Level2/first_game/direction_game1_page.dart';
import 'Screens/LearnerScreen/wordStage/Level3/word_level3_game.dart';
import 'Screens/Level1Screen.dart';
import 'Screens/Login/ParentForgetPassword/change_password_screen.dart';
import 'Screens/Login/ParentForgetPassword/forgot_password_screen.dart';
import 'Screens/Login/login_screen_gaurdian.dart';
import 'Screens/Login/login_screen_user.dart';
import 'Screens/Login/ParentForgetPassword/otp_verification_screen.dart';
import 'Screens/Login/LearnerForgetPassword/user_change_password_screen.dart';
import 'Screens/Login/LearnerForgetPassword/user_forgot_password_screen.dart';
import 'Screens/Login/LearnerForgetPassword/user_otp_verification_screen.dart';
import 'Screens/ParentScreen/ParentMain.dart';
import 'Screens/exercises_levels_screen.dart';
import 'Screens/level_screen.dart';
import 'Screens/object_detection_exercise_screen.dart';
import 'Services/user_service.dart';
import 'SplashLoadingScreen.dart';
import 'models/level.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileapp/Services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // 🔔 Don't call NotificationService.init() here - call it after user is logged in
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp ({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Widget _initialScreen = const SplashLoadingScreen(); // Show this until loaded
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadInitialScreen();
  }

  void _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _loadInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved locale from preferences
    final String? savedLocaleCode = prefs.getString('locale');
    if (savedLocaleCode != null) {
      _locale = Locale(savedLocaleCode);
    }

    // await prefs.setBool('hasShownCourseTutorial', false);
    // await prefs.setBool('hasShownCoursePageTutorial', false);
    // await prefs.setBool('parentTutorialSeen', false);

    final bool onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

    if (!onboardingSeen) {
      setState(() {
        _initialScreen = OnboardingScreen(onLocaleChange: _setLocale);
      });
      return;
    }

    final String? userId = prefs.getString('userId');
    final String? userRole = prefs.getString('role');
    final String? refreshToken = prefs.getString('refreshToken');
    final String? accessToken = prefs.getString('accessToken');

    if (userId != null && userRole != null && refreshToken != null && refreshToken.isNotEmpty) {
      // 🔔 Initialize notification service with user data after confirming user is logged in
      await NotificationService.init();
      
      if (userRole == "parent") {
        final parent = await UserService.getParentById(userId);
        if (parent != null) {
          await NotificationService.updateLastOpened();
          setState(() {
            _initialScreen = ParentMain(parent: parent, onLocaleChange: _setLocale);
          });
          return;
        }
      } else if (userRole == "learner") {
        final learner = await UserService.getLearnerById(userId);
        if (learner != null) {
          await NotificationService.updateLastOpened();
          setState(() {
            _initialScreen = LearnerHomeScreen(learner: learner, onLocaleChange: _setLocale);
          });
          return;
        }
      }
    }

    // Fallback
    setState(() {
      _initialScreen = IntroScreen(onLocaleChange: _setLocale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: _initialScreen,
        routes: {
          '/intro': (context) => IntroScreen(onLocaleChange: _setLocale),
          '/quiz': (context) => TestSelectorWidget(userProgress: 0.3),

          '/login_user': (context) => LoginScreenUser(onLocaleChange: _setLocale),
          '/login_gaurdian': (context) => LoginScreenGaurdian(onLocaleChange: _setLocale),

          '/forgot-password': (context) => ForgotPasswordPage(onLocaleChange: _setLocale),
          '/otp-verification': (context) => OTPVerificationScreen(onLocaleChange: _setLocale),
          '/change-password': (context) => ChangePasswordScreen(onLocaleChange: _setLocale),
          '/user-forgot-password': (context) => UserForgotPasswordPage(onLocaleChange: _setLocale),
          '/user-otp-verification': (context) => UserOTPVerificationScreen(onLocaleChange: _setLocale),
          '/user-change-password': (context) => UserChangePasswordScreen(onLocaleChange: _setLocale),

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

          '/Learner-Home': (context) {
            final learner = ModalRoute.of(context)!.settings.arguments as Learner;
            return LearnerHomeScreen(
              onLocaleChange: _setLocale,
              learner: learner,
            );
          },
          '/exercise-levels': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ExerciseLevelsScreen(
              exerciseId: args['exerciseId'] as String,
              exerciseName: args['exerciseName'] as String,
              exerciseArabicName: args['exerciseArabicName'] as String,
              learner: args['learner'] as Learner,
            );
          },
          '/games': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return LevelScreen(
              level: args['level'] as Level,
              learner: args['learner'] as Learner,
              exerciseId: args['exerciseId'] as String,
              levelObjectId: args['levelObjectId'] as String,
              exerciseImageUrl: args['exerciseImageUrl'] as String,
            );
          },

          // LETTER STAGE

          // LEVEL CONTENT
          '/letters_level_1': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }

            return LetterLevel1(
                exerciseId: args['exerciseId'],
                levelId: args['levelId'],
                learner: args['learner']
            );
          },
          '/letters_level_2': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }

            return LetterLevel2(
                exerciseId: args['exerciseId'],
                levelId: args['levelId'],
                learner: args['learner']
            );
          },
          '/letters_level_3': (context) => const LetterLevel3(),

          // LEVEL1 GAMES
          '/letters_game_1': (context) => const ArabicLetterTracingExercise(),

          // LEVEL2 GAMES
          '/letters_game_3': (context) => const LetterLevel2Game(),
          '/letters_game_4': (context) => const LetterLevel2Game2(),

          // LEVEL3 GAMES
          '/letters_game_5': (context) => const LetterLevel3Game(),

          // WORD STAGE GAMES

          // STAGE CONTENT

          '/words_level_1': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }

            return WordPronunciationScreen(
              onLocaleChange: _setLocale,
              initialLearner: args['learner'],
              exerciseId: args['exerciseId'],
              levelId: args['levelId'], // This is now the MongoDB ObjectId
            );
          },
          '/words_level_2': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }

            return WordPronunciationScreen(
              onLocaleChange: _setLocale,
              initialLearner: args['learner'],
              exerciseId: args['exerciseId'],
              levelId: args['levelId'], // This is now the MongoDB ObjectId
            );
          },
          '/words_level_3': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }

            return WordPronunciationScreen(
              onLocaleChange: _setLocale,
              initialLearner: args['learner'],
              exerciseId: args['exerciseId'],
              levelId: args['levelId'], // This is now the MongoDB ObjectId
            );
          },

          // LEVEL 1 GAMES
          '/words_game_1': (context) => const SpellingGameScreen("Beginner"),

          // LEVEL 2 GAMES
          '/words_game_2': (context) => DirectionInstructionsPage(),
          '/words_game_3': (context) => DirectionInstructionsSecondPage(),
          '/words_game_5': (context) => const SpellingGameScreen("Intermediate"),
          '/words_game_4': (context) => Level1CameraScreen(),

          // LEVEL 3 GAMES
          '/words_game_9': (context) => const MonthsOrderGameScreen(),
          '/words_game_7': (context) => const SpellingGameScreen("Advanced"),

          // SENTENCE STAGE

          // STAGE CONTENT

          '/sentences_level_1': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Missing arguments')),
              );
            }
            return SentencePronunciationScreen(
              onLocaleChange: _setLocale,
              learner: args['learner'],
              exerciseId: args['exerciseId'],
              levelId: args['levelId'], // Changed from levelObjectId to levelId
            );
          },

          // Sentence Games

          '/sentences_game_1': (context) => const SentenceOrderingGameScreen("Beginner"),
          '/sentences_game_2': (context) => const SentenceOrderingGameScreen("Intermediate"),
          '/sentences_game_3': (context) => const SentenceOrderingGameScreen("Advanced"),



          // STORY STAGE GAMES

          // LEVEL 1 GAMES
          '/story_game_1': (context) => StoryInputScreen(),

          // LEVEL 2 GAMES
          '/story_game_2': (context) => const ArabicStorySummarizeWidget(),

        },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Unknown Route: ${settings.name}'),
          ),
        ),
      ),
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