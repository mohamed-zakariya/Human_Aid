// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "${count} attempts left";

  static String m1(name) => "${name} Dashboard";

  static String m2(percent) => "${percent}%";

  static String m3(score, total) =>
      "🎉 Great job! Your score: ${score} out of ${total}";

  static String m4(name) => "Hello ${name}";

  static String m5(percent) => "${percent}% completed";

  static String m6(points) => "${points} pts";

  static String m7(error) => "Error: ${error}";

  static String m8(error) => "Error starting recording: ${error}";

  static String m9(current, total) => "Round ${current} of ${total}";

  static String m10(letter) => "📝 Trace this letter: ${letter}";

  static String m11(score, total) =>
      "😊 Good try! Your score: ${score} out of ${total}";

  static String m12(letter) => "❌ Wrong! The correct letter is: ${letter}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ParentNavBarHome": MessageLookupByLibrary.simpleMessage("Home"),
        "ParentNavBarLogout": MessageLookupByLibrary.simpleMessage("Logout"),
        "ParentNavBarSettings":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addNewLearner":
            MessageLookupByLibrary.simpleMessage("Add New Learner"),
        "add_word": MessageLookupByLibrary.simpleMessage("Add Word"),
        "adultSignupTitle":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "attemptsLeft": m0,
        "availableExercises":
            MessageLookupByLibrary.simpleMessage("Available Exercises"),
        "bottomNavCourses": MessageLookupByLibrary.simpleMessage("Courses"),
        "bottomNavHome": MessageLookupByLibrary.simpleMessage("Home"),
        "bottomNavMenu": MessageLookupByLibrary.simpleMessage("Menu"),
        "bottomNavProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "button1": MessageLookupByLibrary.simpleMessage("Start"),
        "button2": MessageLookupByLibrary.simpleMessage("Continue"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "categories": MessageLookupByLibrary.simpleMessage("Categories"),
        "changePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "changepasswordHint": MessageLookupByLibrary.simpleMessage("Password"),
        "clear": MessageLookupByLibrary.simpleMessage("🧹 Clear"),
        "clickToAddLearners": MessageLookupByLibrary.simpleMessage(
            "Click the + button to add learners."),
        "completedAllLetters": MessageLookupByLibrary.simpleMessage(
            "🎉 You\'ve completed all letters!"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "confirmPasswordRequired": MessageLookupByLibrary.simpleMessage(
            "Confirm password is required"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueLearning":
            MessageLookupByLibrary.simpleMessage("Continue Learning"),
        "continuesignuptitle":
            MessageLookupByLibrary.simpleMessage("Child Registration"),
        "correctAnswer": MessageLookupByLibrary.simpleMessage("🎉 Correct!"),
        "createAccountGaurdian":
            MessageLookupByLibrary.simpleMessage("Create a gaurdian account"),
        "createAccountUser":
            MessageLookupByLibrary.simpleMessage("Create a user account"),
        "createaccountbutton":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "dashboardTitle": m1,
        "dashboard_title":
            MessageLookupByLibrary.simpleMessage("\'s Dashboard"),
        "desc1": MessageLookupByLibrary.simpleMessage(
            "I\'m your friend (the app). Let me take you on a daily journey of progress and growth."),
        "desc2": MessageLookupByLibrary.simpleMessage(
            "It will be a fun journey, step by step, until you become an expert."),
        "desc3": MessageLookupByLibrary.simpleMessage("Nothing can stop you."),
        "done": MessageLookupByLibrary.simpleMessage("✅ Done"),
        "dontWorry":
            MessageLookupByLibrary.simpleMessage("Don’t worry, it’s okay"),
        "emailExist": MessageLookupByLibrary.simpleMessage(
            "This email is already registered"),
        "emailHint": MessageLookupByLibrary.simpleMessage("humanid@gmail.com"),
        "emailHint2":
            MessageLookupByLibrary.simpleMessage("******aid@gmail.com"),
        "emailInvalid":
            MessageLookupByLibrary.simpleMessage("Enter a valid email address"),
        "emailRequired":
            MessageLookupByLibrary.simpleMessage("Email must be entered"),
        "encouragementMessage": MessageLookupByLibrary.simpleMessage(
            "👏 Well done! You traced all 28 Arabic letters!"),
        "errorEmptyEmail":
            MessageLookupByLibrary.simpleMessage("Email cannot be empty"),
        "errorEmptyPassword":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty"),
        "errorLoadingLevels":
            MessageLookupByLibrary.simpleMessage("Error loading levels"),
        "exercise2Title": MessageLookupByLibrary.simpleMessage("Exercise 2"),
        "exerciseProgressLabel":
            MessageLookupByLibrary.simpleMessage("Progress"),
        "exerciseProgressPercent": m2,
        "explore_message": MessageLookupByLibrary.simpleMessage(
            "Let\'s explore some insights today"),
        "feedbackWidgetAnalyzing":
            MessageLookupByLibrary.simpleMessage("Analyzing..."),
        "finishTracing":
            MessageLookupByLibrary.simpleMessage("✅ Finish Tracing"),
        "fishGameTitle":
            MessageLookupByLibrary.simpleMessage("Fish Game with Letters"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "forgotPasswordHint": MessageLookupByLibrary.simpleMessage(
            "Enter your registered phone or email"),
        "forgotPasswordTitle":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "games": MessageLookupByLibrary.simpleMessage("Games"),
        "genderFemale": MessageLookupByLibrary.simpleMessage("Female"),
        "genderMale": MessageLookupByLibrary.simpleMessage("Male"),
        "genderSelect": MessageLookupByLibrary.simpleMessage("Select Gender"),
        "genderSelected": MessageLookupByLibrary.simpleMessage("Selected:"),
        "gotIt": MessageLookupByLibrary.simpleMessage("Got it!"),
        "greatJob": m3,
        "greatJob2": MessageLookupByLibrary.simpleMessage("🎉 Great job!"),
        "greeting": m4,
        "guardianButton": MessageLookupByLibrary.simpleMessage("Guardian"),
        "guardianDescription": MessageLookupByLibrary.simpleMessage(
            "Registering as a guardian allows you to track and follow the progress of your loved ones, whether they are your children, students, or anyone under your responsibility."),
        "guardianTitle": MessageLookupByLibrary.simpleMessage(
            "Register for someone you care about"),
        "helloLabel": MessageLookupByLibrary.simpleMessage("Hello,"),
        "howToPlayDescription": MessageLookupByLibrary.simpleMessage(
            "Listen to the letter and find the matching fish. Tap on the correct fish. Earn a point for each correct answer!"),
        "howToPlayTitle": MessageLookupByLibrary.simpleMessage("How to Play"),
        "howToTrace": MessageLookupByLibrary.simpleMessage("📚 How to Trace"),
        "ignoredRecording":
            MessageLookupByLibrary.simpleMessage("Recording ignored"),
        "instructions": MessageLookupByLibrary.simpleMessage(
            "1. Trace the letter with your finger.\n2. Try to stay on the shape.\n3. Press Done when finished."),
        "introTitle": MessageLookupByLibrary.simpleMessage(
            "How would you like to register?"),
        "invalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Invalid username or password. Please try again."),
        "learner_members":
            MessageLookupByLibrary.simpleMessage("Learner Members"),
        "learner_progress":
            MessageLookupByLibrary.simpleMessage("Learners Progress"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "levelLabel": MessageLookupByLibrary.simpleMessage("Stage 2 • Level 1"),
        "levels": MessageLookupByLibrary.simpleMessage("Levels"),
        "listen": MessageLookupByLibrary.simpleMessage("Listen"),
        "listenToLetter":
            MessageLookupByLibrary.simpleMessage("Listen to Letter"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("Login"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Next"),
        "noAccount":
            MessageLookupByLibrary.simpleMessage("Don’t have an account?"),
        "noExercisesAvailable":
            MessageLookupByLibrary.simpleMessage("No exercises available"),
        "noGamesAvailable": MessageLookupByLibrary.simpleMessage(
            "No games available for this level"),
        "noLevelsAvailable": MessageLookupByLibrary.simpleMessage(
            "No levels available for this exercise"),
        "noWordsAvailable": MessageLookupByLibrary.simpleMessage(
            "No words available at this level."),
        "no_progress_data":
            MessageLookupByLibrary.simpleMessage("No data available."),
        "okButton": MessageLookupByLibrary.simpleMessage("OK"),
        "orContinueWith":
            MessageLookupByLibrary.simpleMessage("or continue with"),
        "otpPrompt": MessageLookupByLibrary.simpleMessage(
            "Please enter the verification code"),
        "outOfTries": MessageLookupByLibrary.simpleMessage(
            "No attempts left! Moving to the next word..."),
        "passwordHint": MessageLookupByLibrary.simpleMessage("●●●●●●●"),
        "passwordMismatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "passwordRequired":
            MessageLookupByLibrary.simpleMessage("Password must be entered"),
        "passwordShort": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 8 characters"),
        "phoneHint": MessageLookupByLibrary.simpleMessage("+20******336"),
        "phonenumbersearch": MessageLookupByLibrary.simpleMessage("search"),
        "playGame": MessageLookupByLibrary.simpleMessage("Play Now"),
        "processingError": MessageLookupByLibrary.simpleMessage(
            "An error occurred while processing"),
        "processingRecording": MessageLookupByLibrary.simpleMessage(
            "Processing your recording..."),
        "progressCompleted": m5,
        "progressPoints": m6,
        "recordingError": m7,
        "recordingStartError": m8,
        "recordingTimeout": MessageLookupByLibrary.simpleMessage(
            "Recording time limit reached!"),
        "restart": MessageLookupByLibrary.simpleMessage("Restart"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "roundLabel": m9,
        "searchCoursesHint":
            MessageLookupByLibrary.simpleMessage("Search courses..."),
        "seeAll": MessageLookupByLibrary.simpleMessage("See All"),
        "selectGameToPlay": MessageLookupByLibrary.simpleMessage(
            "Select a game to start playing"),
        "selectLevelToStart": MessageLookupByLibrary.simpleMessage(
            "Select a level to start playing"),
        "showMore": MessageLookupByLibrary.simpleMessage("Show more"),
        "signup_password_mismatch":
            MessageLookupByLibrary.simpleMessage("Don\'t Match"),
        "signupbutton": MessageLookupByLibrary.simpleMessage("Continue"),
        "signupinputfieldbirthdate":
            MessageLookupByLibrary.simpleMessage("ex:15/7/2002"),
        "signupinputfieldemail":
            MessageLookupByLibrary.simpleMessage("ex:ibrahimzekas@gmail.com"),
        "signupinputfieldname":
            MessageLookupByLibrary.simpleMessage("ex:MohamedZakaria"),
        "signupinputfieldnationality":
            MessageLookupByLibrary.simpleMessage("ex:Egyptian"),
        "signupinputfieldpassword":
            MessageLookupByLibrary.simpleMessage("ex:MyP@ssw0rd123"),
        "signupinputfieldusername":
            MessageLookupByLibrary.simpleMessage("ex:ibrahimzekas123"),
        "signuptitlebirthdate":
            MessageLookupByLibrary.simpleMessage("Birthdate"),
        "signuptitleconfirmpassword":
            MessageLookupByLibrary.simpleMessage("confirm password"),
        "signuptitleemail": MessageLookupByLibrary.simpleMessage("email"),
        "signuptitlename": MessageLookupByLibrary.simpleMessage("Name"),
        "signuptitlenationality":
            MessageLookupByLibrary.simpleMessage("Nationality"),
        "signuptitlepassword": MessageLookupByLibrary.simpleMessage("password"),
        "signuptitlephonenumber":
            MessageLookupByLibrary.simpleMessage("phone number"),
        "signuptitleusername": MessageLookupByLibrary.simpleMessage("username"),
        "submitbutton": MessageLookupByLibrary.simpleMessage("Done"),
        "successLogin":
            MessageLookupByLibrary.simpleMessage("Login successful"),
        "tips": MessageLookupByLibrary.simpleMessage("Tips"),
        "title": MessageLookupByLibrary.simpleMessage("Create Account"),
        "title1": MessageLookupByLibrary.simpleMessage(
            "Welcome to your special world\nwhere learning is fun"),
        "title2": MessageLookupByLibrary.simpleMessage(
            "Together, we will learn to read\nand write Arabic properly"),
        "title3": MessageLookupByLibrary.simpleMessage(
            "Don\'t fear trying,\nkeep going until you break the fear barrier"),
        "traceThisLetter": m10,
        "traceTitle":
            MessageLookupByLibrary.simpleMessage("✍️ Trace the letter"),
        "transcriptLabel": MessageLookupByLibrary.simpleMessage("Transcript"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "tryAgain2": m11,
        "tryAgain3": MessageLookupByLibrary.simpleMessage("❌ Try Again"),
        "userButton": MessageLookupByLibrary.simpleMessage("User"),
        "userDescription": MessageLookupByLibrary.simpleMessage(
            "If you are older than 12, you can now easily register for yourself by clicking the user start button."),
        "userTitle":
            MessageLookupByLibrary.simpleMessage("Register for yourself"),
        "usernameExist": MessageLookupByLibrary.simpleMessage(
            "This username is already taken"),
        "usernameRequired":
            MessageLookupByLibrary.simpleMessage("Username must be entered"),
        "usernameShort": MessageLookupByLibrary.simpleMessage(
            "Username must be at least 3 characters"),
        "view_details": MessageLookupByLibrary.simpleMessage("view Detials"),
        "welcome_message":
            MessageLookupByLibrary.simpleMessage("Welcome Back, "),
        "wrongAnswer": m12
      };
}
