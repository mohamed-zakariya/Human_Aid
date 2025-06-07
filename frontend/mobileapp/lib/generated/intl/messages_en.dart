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

  static String m1(answer) => "Correct answer: ${answer}";

  static String m2(direction) => "The correct direction is ${direction}";

  static String m3(name) => "${name} Dashboard";

  static String m4(item, direction) => "Drag ${item} to ${direction} direction";

  static String m5(letter) => "Draw the letter \"${letter}\"";

  static String m6(percent) => "${percent}%";

  static String m7(score, total) => "Final Score: ${score} out of ${total}";

  static String m8(score, total) =>
      "🎉 Great job! Your score: ${score} out of ${total}";

  static String m9(name) => "Hello ${name}";

  static String m10(level) => "🎉 Amazing! You\'ve completed level ${level}!";

  static String m11(remaining) => "Listen again (${remaining} attempts left)";

  static String m12(count) => "Order ${count} months of the year";

  static String m13(level, count, direction) =>
      "Level ${level}: Order ${count} months ${direction}";

  static String m14(item, direction) =>
      "Place ${item} in ${direction} direction";

  static String m15(count) => "Points: ${count}";

  static String m16(percent) => "${percent}% completed";

  static String m17(points) => "${points} pts";

  static String m18(current, total) => "Question ${current} / ${total}";

  static String m19(error) => "Error: ${error}";

  static String m20(error) => "Error starting recording: ${error}";

  static String m21(current, total) => "Round ${current} of ${total}";

  static String m22(count) => "${count} seconds";

  static String m23(seconds) => "${seconds} seconds remaining";

  static String m24(direction) => "The direction is ${direction}";

  static String m25(count) => "Strokes: ${count}";

  static String m26(letter) => "📝 Trace this letter: ${letter}";

  static String m27(score, total) =>
      "😊 Good try! Your score: ${score} out of ${total}";

  static String m28(letter) => "❌ Wrong! The correct letter is: ${letter}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "LearnerNavBarCourses": MessageLookupByLibrary.simpleMessage("Courses"),
        "LearnerNavBarHome": MessageLookupByLibrary.simpleMessage("Home"),
        "LearnerNavBarMenu": MessageLookupByLibrary.simpleMessage("Menu"),
        "LearnerNavBarProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "ParentNavBarHome": MessageLookupByLibrary.simpleMessage("Home"),
        "ParentNavBarLogout": MessageLookupByLibrary.simpleMessage("Logout"),
        "ParentNavBarSettings":
            MessageLookupByLibrary.simpleMessage("Settings"),
        "Return": MessageLookupByLibrary.simpleMessage("Return"),
        "accuracy": MessageLookupByLibrary.simpleMessage("accuracy"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addNewLearner":
            MessageLookupByLibrary.simpleMessage("Add New Learner"),
        "add_word": MessageLookupByLibrary.simpleMessage("Add Word"),
        "adultSignupTitle":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "all": MessageLookupByLibrary.simpleMessage("all"),
        "amazing": MessageLookupByLibrary.simpleMessage("Amazing! 😎"),
        "apple": MessageLookupByLibrary.simpleMessage("Apple"),
        "arabicLanguage": MessageLookupByLibrary.simpleMessage("العربية"),
        "attemptsLeft": m0,
        "availableExercises":
            MessageLookupByLibrary.simpleMessage("Available Exercises"),
        "ball": MessageLookupByLibrary.simpleMessage("Ball"),
        "book": MessageLookupByLibrary.simpleMessage("Book"),
        "bottomNavCourses": MessageLookupByLibrary.simpleMessage("Courses"),
        "bottomNavHome": MessageLookupByLibrary.simpleMessage("Home"),
        "bottomNavMenu": MessageLookupByLibrary.simpleMessage("Menu"),
        "bottomNavProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "bravo": MessageLookupByLibrary.simpleMessage("Bravo! 👏"),
        "button1": MessageLookupByLibrary.simpleMessage("Start"),
        "button2": MessageLookupByLibrary.simpleMessage("Continue"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("cancel"),
        "car": MessageLookupByLibrary.simpleMessage("Car"),
        "cat": MessageLookupByLibrary.simpleMessage("Cat"),
        "categories": MessageLookupByLibrary.simpleMessage("Categories"),
        "changePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "changepasswordHint": MessageLookupByLibrary.simpleMessage("Password"),
        "chooseLanguageSubtitle": MessageLookupByLibrary.simpleMessage(
            "Select your preferred language"),
        "chooseLanguageTitle":
            MessageLookupByLibrary.simpleMessage("Choose Language"),
        "clear": MessageLookupByLibrary.simpleMessage("🧹 Clear"),
        "clickToAddLearners": MessageLookupByLibrary.simpleMessage(
            "Click the + button to add learners."),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
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
        "correct": MessageLookupByLibrary.simpleMessage("Correct! ✅"),
        "correctAnswer": MessageLookupByLibrary.simpleMessage("🎉 Correct!"),
        "correctAnswerIs": m1,
        "correctDirectionInfo": MessageLookupByLibrary.simpleMessage(
            "After each question, the correct direction will be shown."),
        "correctDirectionIs": m2,
        "correctFeedback":
            MessageLookupByLibrary.simpleMessage("Well done! 🎉"),
        "createAccountGaurdian":
            MessageLookupByLibrary.simpleMessage("Create a gaurdian account"),
        "createAccountUser":
            MessageLookupByLibrary.simpleMessage("Create a user account"),
        "createaccountbutton":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "dashboardTitle": m3,
        "dashboard_title":
            MessageLookupByLibrary.simpleMessage("\'s Dashboard"),
        "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
        "defaultUsername": MessageLookupByLibrary.simpleMessage("username"),
        "desc1": MessageLookupByLibrary.simpleMessage(
            "I\'m your friend (the app). Let me take you on a daily journey of progress and growth."),
        "desc2": MessageLookupByLibrary.simpleMessage(
            "It will be a fun journey, step by step, until you become an expert."),
        "desc3": MessageLookupByLibrary.simpleMessage("Nothing can stop you."),
        "directionExerciseTitle":
            MessageLookupByLibrary.simpleMessage("Direction Exercise"),
        "directions": MessageLookupByLibrary.simpleMessage("Directions"),
        "directionsTitle": MessageLookupByLibrary.simpleMessage("Directions"),
        "done": MessageLookupByLibrary.simpleMessage("✅ Done"),
        "dontGiveUpLearning": MessageLookupByLibrary.simpleMessage(
            "Don\'t give up, learning takes time"),
        "dontWorry":
            MessageLookupByLibrary.simpleMessage("Don’t worry, it’s okay"),
        "dontWorryTryAgain":
            MessageLookupByLibrary.simpleMessage("Don\'t worry, try again"),
        "down": MessageLookupByLibrary.simpleMessage("Down"),
        "downLeft": MessageLookupByLibrary.simpleMessage("Down Left"),
        "downRight": MessageLookupByLibrary.simpleMessage("Down Right"),
        "dragImageToCorrectDirection": MessageLookupByLibrary.simpleMessage(
            "Drag the image to the correct direction"),
        "dragImageToDirection": m4,
        "dragInfo": MessageLookupByLibrary.simpleMessage(
            "Drag the image to the correct direction."),
        "drawInstruction": MessageLookupByLibrary.simpleMessage(
            "Touch and draw anywhere on the canvas"),
        "drawLetter": m5,
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
        "englishLanguage": MessageLookupByLibrary.simpleMessage("English"),
        "errorEmptyEmail":
            MessageLookupByLibrary.simpleMessage("Email cannot be empty"),
        "errorEmptyPassword":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty"),
        "errorLoadingLevels":
            MessageLookupByLibrary.simpleMessage("Error loading levels"),
        "everyTryMakesStronger": MessageLookupByLibrary.simpleMessage(
            "Every try makes you stronger"),
        "excellent": MessageLookupByLibrary.simpleMessage("Excellent! 🎉"),
        "excellentWork": MessageLookupByLibrary.simpleMessage("Excellent work"),
        "exercise2Title": MessageLookupByLibrary.simpleMessage("Exercise 2"),
        "exerciseCompleted":
            MessageLookupByLibrary.simpleMessage("Exercise Completed"),
        "exerciseFinished":
            MessageLookupByLibrary.simpleMessage("Exercise Finished"),
        "exerciseInfoTitle":
            MessageLookupByLibrary.simpleMessage("Exercise Information"),
        "exerciseProgressLabel":
            MessageLookupByLibrary.simpleMessage("Progress"),
        "exerciseProgressPercent": m6,
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "exitExerciseQuestion": MessageLookupByLibrary.simpleMessage(
            "Do you want to exit the exercise?"),
        "explore_message": MessageLookupByLibrary.simpleMessage(
            "Let\'s explore some insights today"),
        "feedbackWidgetAnalyzing":
            MessageLookupByLibrary.simpleMessage("Analyzing..."),
        "finalLevelSuccess": MessageLookupByLibrary.simpleMessage(
            "🌟 Incredible! You\'ve mastered all month orders!"),
        "finalScore": m7,
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
        "gameCompleted": MessageLookupByLibrary.simpleMessage("Completed!"),
        "gameFinished": MessageLookupByLibrary.simpleMessage("Game Over!"),
        "gameName": MessageLookupByLibrary.simpleMessage("Direction Game"),
        "gameOverTitle": MessageLookupByLibrary.simpleMessage("🎮 Game Over"),
        "games": MessageLookupByLibrary.simpleMessage("Games"),
        "genderFemale": MessageLookupByLibrary.simpleMessage("Female"),
        "genderMale": MessageLookupByLibrary.simpleMessage("Male"),
        "genderSelect": MessageLookupByLibrary.simpleMessage("Select Gender"),
        "genderSelected": MessageLookupByLibrary.simpleMessage("Selected:"),
        "gotIt": MessageLookupByLibrary.simpleMessage("Got it!"),
        "greatJob": m8,
        "greatJob2": MessageLookupByLibrary.simpleMessage("🎉 Great job!"),
        "greatJobMotivation": MessageLookupByLibrary.simpleMessage(
            "🎉 Great job! You\'re doing amazing!"),
        "greeting": m9,
        "guardianButton": MessageLookupByLibrary.simpleMessage("Guardian"),
        "guardianDescription": MessageLookupByLibrary.simpleMessage(
            "Registering as a guardian allows you to track and follow the progress of your loved ones, whether they are your children, students, or anyone under your responsibility."),
        "guardianTitle": MessageLookupByLibrary.simpleMessage(
            "Register for someone you care about"),
        "helloLabel": MessageLookupByLibrary.simpleMessage("Hello,"),
        "help": MessageLookupByLibrary.simpleMessage("Help"),
        "howToPlayDescription": MessageLookupByLibrary.simpleMessage(
            "Listen to the letter and find the matching fish. Tap on the correct fish. Earn a point for each correct answer!"),
        "howToPlayTitle": MessageLookupByLibrary.simpleMessage("How to Play"),
        "howToTrace": MessageLookupByLibrary.simpleMessage("📚 How to Trace"),
        "ignoredRecording":
            MessageLookupByLibrary.simpleMessage("Recording ignored"),
        "incorrect": MessageLookupByLibrary.simpleMessage("Wrong! ❌"),
        "info":
            MessageLookupByLibrary.simpleMessage("Information about Training"),
        "instruction1": MessageLookupByLibrary.simpleMessage(
            "Drag the letters into the correct order."),
        "instruction2": MessageLookupByLibrary.simpleMessage(
            "If the answer is correct, you\'ll get a new word."),
        "instruction3": MessageLookupByLibrary.simpleMessage(
            "Try to complete all words and get a high score!"),
        "instructionAnswerShown": MessageLookupByLibrary.simpleMessage(
            "After each question, the correct answer will be shown."),
        "instructionLookCarefully": MessageLookupByLibrary.simpleMessage(
            "Look carefully at the direction shape and choose the correct sentence."),
        "instructionSpeech": MessageLookupByLibrary.simpleMessage(
            "Each question has 8 seconds to answer. Drag the image to the correct direction. After each question, the correct direction will be shown."),
        "instructionTimer": MessageLookupByLibrary.simpleMessage(
            "Each question has 5 seconds to answer."),
        "instructions": MessageLookupByLibrary.simpleMessage(
            "1. Trace the letter with your finger.\n2. Try to stay on the shape.\n3. Press Done when finished."),
        "instructionsTitle":
            MessageLookupByLibrary.simpleMessage("How to Play"),
        "introTitle": MessageLookupByLibrary.simpleMessage(
            "How would you like to register?"),
        "invalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Invalid username or password. Please try again."),
        "keepProgressing":
            MessageLookupByLibrary.simpleMessage("Keep progressing"),
        "keepTryingProgressing": MessageLookupByLibrary.simpleMessage(
            "Keep trying, you\'re progressing"),
        "learner_members":
            MessageLookupByLibrary.simpleMessage("Learner Members"),
        "learner_progress":
            MessageLookupByLibrary.simpleMessage("Learners Progress"),
        "learningNeedsPatience":
            MessageLookupByLibrary.simpleMessage("Learning needs patience"),
        "left": MessageLookupByLibrary.simpleMessage("Left"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "levelFailure": MessageLookupByLibrary.simpleMessage(
            "Don\'t worry! Practice makes perfect. Try this level again!"),
        "levelLabel": MessageLookupByLibrary.simpleMessage("spell the word"),
        "levelRetry": MessageLookupByLibrary.simpleMessage(
            "Keep going! You\'re getting better with each try!"),
        "levelSuccess": m10,
        "levels": MessageLookupByLibrary.simpleMessage("Levels"),
        "listen": MessageLookupByLibrary.simpleMessage("Listen"),
        "listenAgain": m11,
        "listenToLetter":
            MessageLookupByLibrary.simpleMessage("Listen to Letter"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("Login"),
        "logoutButton": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutConfirmationMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to logout?\nYou will need to sign in again."),
        "logoutConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("Logout Confirmation"),
        "logoutSubtitle":
            MessageLookupByLibrary.simpleMessage("Sign out securely"),
        "monthsOrderHeader": m12,
        "monthsOrderHelpDrag": MessageLookupByLibrary.simpleMessage(
            "Drag the months from below and place them in the correct order"),
        "monthsOrderHelpListen": MessageLookupByLibrary.simpleMessage(
            "Tap the month to hear its name"),
        "monthsOrderHelpOrder": MessageLookupByLibrary.simpleMessage(
            "Order the months from January to the last month in the level"),
        "monthsOrderHelpTranslate": MessageLookupByLibrary.simpleMessage(
            "Tap the translate button to switch between Arabic and Levantine names"),
        "monthsOrderLevelInstruction": m13,
        "monthsOrderList": MessageLookupByLibrary.simpleMessage(
            "يناير, فبراير, مارس, أبريل, مايو, يونيو, يوليو, أغسطس, سبتمبر, أكتوبر, نوفمبر, ديسمبر"),
        "monthsOrderSuccess": MessageLookupByLibrary.simpleMessage(
            "Great job! You\'ve ordered the months correctly."),
        "monthsOrderTitle":
            MessageLookupByLibrary.simpleMessage("Order the Months"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
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
        "orderAscending":
            MessageLookupByLibrary.simpleMessage("from first to last"),
        "orderDescending":
            MessageLookupByLibrary.simpleMessage("from last to first"),
        "orderMonthsCorrectly":
            MessageLookupByLibrary.simpleMessage("Order the months correctly."),
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
        "placeImageInDirection": m14,
        "playAgain": MessageLookupByLibrary.simpleMessage("Play Again"),
        "playGame": MessageLookupByLibrary.simpleMessage("Play Now"),
        "pointCount": m15,
        "processingError": MessageLookupByLibrary.simpleMessage(
            "An error occurred while processing"),
        "processingRecording": MessageLookupByLibrary.simpleMessage(
            "Processing your recording..."),
        "progressCompleted": m16,
        "progressPoints": m17,
        "progressWillBeLost":
            MessageLookupByLibrary.simpleMessage("Your progress will be lost"),
        "questionProgress": m18,
        "recordingError": m19,
        "recordingStartError": m20,
        "recordingTimeout": MessageLookupByLibrary.simpleMessage(
            "Recording time limit reached!"),
        "restart": MessageLookupByLibrary.simpleMessage("Restart"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "right": MessageLookupByLibrary.simpleMessage("Right"),
        "roundLabel": m21,
        "roundLabel2": MessageLookupByLibrary.simpleMessage("Round"),
        "searchCoursesHint":
            MessageLookupByLibrary.simpleMessage("Search courses..."),
        "seconds": m22,
        "secondsRemaining": m23,
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
        "speakDirectionTemplate": m24,
        "spellingGame": MessageLookupByLibrary.simpleMessage("Spelling Game"),
        "startExercise": MessageLookupByLibrary.simpleMessage("Start Exercise"),
        "strokeCount": m25,
        "submitbutton": MessageLookupByLibrary.simpleMessage("Done"),
        "successLogin":
            MessageLookupByLibrary.simpleMessage("Login successful"),
        "tapArrowToHear": MessageLookupByLibrary.simpleMessage(
            "Tap the arrow to hear the direction"),
        "tapToHearDirection": MessageLookupByLibrary.simpleMessage(
            "Tap the arrow to hear the direction"),
        "timeLabel": MessageLookupByLibrary.simpleMessage("Time"),
        "timerInfo": MessageLookupByLibrary.simpleMessage(
            "Each question has 8 seconds to answer."),
        "tips": MessageLookupByLibrary.simpleMessage("Tips"),
        "title": MessageLookupByLibrary.simpleMessage("Create Account"),
        "title1": MessageLookupByLibrary.simpleMessage(
            "Welcome to your special world\nwhere learning is fun"),
        "title2": MessageLookupByLibrary.simpleMessage(
            "Together, we will learn to read\nand write Arabic properly"),
        "title3": MessageLookupByLibrary.simpleMessage(
            "Don\'t fear trying,\nkeep going until you break the fear barrier"),
        "traceThisLetter": m26,
        "traceTitle":
            MessageLookupByLibrary.simpleMessage("✍️ Trace the letter"),
        "transcriptLabel": MessageLookupByLibrary.simpleMessage("Transcript"),
        "translateMonthsTooltip":
            MessageLookupByLibrary.simpleMessage("Switch month names"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "tryAgain2": m27,
        "tryAgain3": MessageLookupByLibrary.simpleMessage("❌ Try Again"),
        "tryAgainEncouragement":
            MessageLookupByLibrary.simpleMessage("Try again! 💪"),
        "tryAgainMotivation": MessageLookupByLibrary.simpleMessage(
            "💪 Keep going! You can do it!"),
        "tryingHardGreat": MessageLookupByLibrary.simpleMessage(
            "You\'re trying hard, that\'s great"),
        "tryingIsFirstStep":
            MessageLookupByLibrary.simpleMessage("Trying is the first step"),
        "ttsInstructions": MessageLookupByLibrary.simpleMessage(
            "Each question has 5 seconds to answer. Look carefully at the direction shape and choose the correct sentence. After each question, the correct answer will be shown."),
        "up": MessageLookupByLibrary.simpleMessage("Up"),
        "upLeft": MessageLookupByLibrary.simpleMessage("Up Left"),
        "upRight": MessageLookupByLibrary.simpleMessage("Up Right"),
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
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "veryGreat": MessageLookupByLibrary.simpleMessage("Very great"),
        "verySmart": MessageLookupByLibrary.simpleMessage("You\'re very smart"),
        "view_details": MessageLookupByLibrary.simpleMessage("view Detials"),
        "welcome_message":
            MessageLookupByLibrary.simpleMessage("Welcome Back, "),
        "wellDone": MessageLookupByLibrary.simpleMessage("Well done! ✅"),
        "whatIsDirection":
            MessageLookupByLibrary.simpleMessage("What is the direction?"),
        "wordsGame3Title": MessageLookupByLibrary.simpleMessage("Months Game"),
        "wrongAnswer": m28,
        "wrongFeedback": MessageLookupByLibrary.simpleMessage("Try again"),
        "youTracedCorrectly": MessageLookupByLibrary.simpleMessage(
            "You traced the letter correctly!")
      };
}
