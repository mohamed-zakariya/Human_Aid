// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Create Account`
  String get title {
    return Intl.message(
      'Create Account',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get signuptitlename {
    return Intl.message(
      'Name',
      name: 'signuptitlename',
      desc: '',
      args: [],
    );
  }

  /// `ex:MohamedZakaria`
  String get signupinputfieldname {
    return Intl.message(
      'ex:MohamedZakaria',
      name: 'signupinputfieldname',
      desc: '',
      args: [],
    );
  }

  /// `username`
  String get signuptitleusername {
    return Intl.message(
      'username',
      name: 'signuptitleusername',
      desc: '',
      args: [],
    );
  }

  /// `ex:ibrahimzekas123`
  String get signupinputfieldusername {
    return Intl.message(
      'ex:ibrahimzekas123',
      name: 'signupinputfieldusername',
      desc: '',
      args: [],
    );
  }

  /// `email`
  String get signuptitleemail {
    return Intl.message(
      'email',
      name: 'signuptitleemail',
      desc: '',
      args: [],
    );
  }

  /// `ex:ibrahimzekas@gmail.com`
  String get signupinputfieldemail {
    return Intl.message(
      'ex:ibrahimzekas@gmail.com',
      name: 'signupinputfieldemail',
      desc: '',
      args: [],
    );
  }

  /// `phone number`
  String get signuptitlephonenumber {
    return Intl.message(
      'phone number',
      name: 'signuptitlephonenumber',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get signuptitlepassword {
    return Intl.message(
      'password',
      name: 'signuptitlepassword',
      desc: '',
      args: [],
    );
  }

  /// `ex:MyP@ssw0rd123`
  String get signupinputfieldpassword {
    return Intl.message(
      'ex:MyP@ssw0rd123',
      name: 'signupinputfieldpassword',
      desc: '',
      args: [],
    );
  }

  /// `confirm password`
  String get signuptitleconfirmpassword {
    return Intl.message(
      'confirm password',
      name: 'signuptitleconfirmpassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't Match`
  String get signup_password_mismatch {
    return Intl.message(
      'Don\'t Match',
      name: 'signup_password_mismatch',
      desc: '',
      args: [],
    );
  }

  /// `Birthdate`
  String get signuptitlebirthdate {
    return Intl.message(
      'Birthdate',
      name: 'signuptitlebirthdate',
      desc: '',
      args: [],
    );
  }

  /// `ex:15/7/2002`
  String get signupinputfieldbirthdate {
    return Intl.message(
      'ex:15/7/2002',
      name: 'signupinputfieldbirthdate',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get signuptitlenationality {
    return Intl.message(
      'Nationality',
      name: 'signuptitlenationality',
      desc: '',
      args: [],
    );
  }

  /// `ex:Egyptian`
  String get signupinputfieldnationality {
    return Intl.message(
      'ex:Egyptian',
      name: 'signupinputfieldnationality',
      desc: '',
      args: [],
    );
  }

  /// `search`
  String get phonenumbersearch {
    return Intl.message(
      'search',
      name: 'phonenumbersearch',
      desc: '',
      args: [],
    );
  }

  /// `Select Gender`
  String get genderSelect {
    return Intl.message(
      'Select Gender',
      name: 'genderSelect',
      desc: '',
      args: [],
    );
  }

  /// `Selected:`
  String get genderSelected {
    return Intl.message(
      'Selected:',
      name: 'genderSelected',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get genderMale {
    return Intl.message(
      'Male',
      name: 'genderMale',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get genderFemale {
    return Intl.message(
      'Female',
      name: 'genderFemale',
      desc: '',
      args: [],
    );
  }

  /// `Child Registration`
  String get continuesignuptitle {
    return Intl.message(
      'Child Registration',
      name: 'continuesignuptitle',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createaccountbutton {
    return Intl.message(
      'Create Account',
      name: 'createaccountbutton',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get signupbutton {
    return Intl.message(
      'Continue',
      name: 'signupbutton',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get parentNavBarHome {
    return Intl.message(
      'Home',
      name: 'parentNavBarHome',
      desc: '',
      args: [],
    );
  }

  /// `Choose Language`
  String get parentNavBarChangeLanguage {
    return Intl.message(
      'Choose Language',
      name: 'parentNavBarChangeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get parentNavBarSettings {
    return Intl.message(
      'Settings',
      name: 'parentNavBarSettings',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get parentNavBarLogout {
    return Intl.message(
      'Logout',
      name: 'parentNavBarLogout',
      desc: '',
      args: [],
    );
  }

  /// `Username must be entered`
  String get usernameRequired {
    return Intl.message(
      'Username must be entered',
      name: 'usernameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters`
  String get usernameShort {
    return Intl.message(
      'Username must be at least 3 characters',
      name: 'usernameShort',
      desc: '',
      args: [],
    );
  }

  /// `This username is already taken`
  String get usernameExist {
    return Intl.message(
      'This username is already taken',
      name: 'usernameExist',
      desc: '',
      args: [],
    );
  }

  /// `Email must be entered`
  String get emailRequired {
    return Intl.message(
      'Email must be entered',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get emailInvalid {
    return Intl.message(
      'Enter a valid email address',
      name: 'emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `This email is already registered`
  String get emailExist {
    return Intl.message(
      'This email is already registered',
      name: 'emailExist',
      desc: '',
      args: [],
    );
  }

  /// `Password must be entered`
  String get passwordRequired {
    return Intl.message(
      'Password must be entered',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get passwordShort {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'passwordShort',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password is required`
  String get confirmPasswordRequired {
    return Intl.message(
      'Confirm password is required',
      name: 'confirmPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get adultSignupTitle {
    return Intl.message(
      'Create Account',
      name: 'adultSignupTitle',
      desc: '',
      args: [],
    );
  }

  /// `'s Dashboard`
  String get dashboard_title {
    return Intl.message(
      '\'s Dashboard',
      name: 'dashboard_title',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back, `
  String get welcome_message {
    return Intl.message(
      'Welcome Back, ',
      name: 'welcome_message',
      desc: '',
      args: [],
    );
  }

  /// `Let's explore some insights today`
  String get explore_message {
    return Intl.message(
      'Let\'s explore some insights today',
      name: 'explore_message',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get tips {
    return Intl.message(
      'Tips',
      name: 'tips',
      desc: '',
      args: [],
    );
  }

  /// `Learner Members`
  String get learner_members {
    return Intl.message(
      'Learner Members',
      name: 'learner_members',
      desc: '',
      args: [],
    );
  }

  /// `Add Word`
  String get add_word {
    return Intl.message(
      'Add Word',
      name: 'add_word',
      desc: '',
      args: [],
    );
  }

  /// `Learners Progress`
  String get learner_progress {
    return Intl.message(
      'Learners Progress',
      name: 'learner_progress',
      desc: '',
      args: [],
    );
  }

  /// `No data available.`
  String get no_progress_data {
    return Intl.message(
      'No data available.',
      name: 'no_progress_data',
      desc: '',
      args: [],
    );
  }

  /// `view Detials`
  String get view_details {
    return Intl.message(
      'view Detials',
      name: 'view_details',
      desc: '',
      args: [],
    );
  }

  /// `Add New Learner`
  String get addNewLearner {
    return Intl.message(
      'Add New Learner',
      name: 'addNewLearner',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Click the + button to add learners.`
  String get clickToAddLearners {
    return Intl.message(
      'Click the + button to add learners.',
      name: 'clickToAddLearners',
      desc: '',
      args: [],
    );
  }

  /// `Show more`
  String get showMore {
    return Intl.message(
      'Show more',
      name: 'showMore',
      desc: '',
      args: [],
    );
  }

  /// `{name} Dashboard`
  String dashboardTitle(Object name) {
    return Intl.message(
      '$name Dashboard',
      name: 'dashboardTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Exercise 2`
  String get exercise2Title {
    return Intl.message(
      'Exercise 2',
      name: 'exercise2Title',
      desc: '',
      args: [],
    );
  }

  /// `Fish Game with Letters`
  String get fishGameTitle {
    return Intl.message(
      'Fish Game with Letters',
      name: 'fishGameTitle',
      desc: '',
      args: [],
    );
  }

  /// `Round {current} of {total}`
  String roundLabel(Object current, Object total) {
    return Intl.message(
      'Round $current of $total',
      name: 'roundLabel',
      desc: '',
      args: [current, total],
    );
  }

  /// `Listen to Letter`
  String get listenToLetter {
    return Intl.message(
      'Listen to Letter',
      name: 'listenToLetter',
      desc: '',
      args: [],
    );
  }

  /// `How to Play`
  String get howToPlayTitle {
    return Intl.message(
      'How to Play',
      name: 'howToPlayTitle',
      desc: '',
      args: [],
    );
  }

  /// `Listen to the letter and find the matching fish. Tap on the correct fish. Earn a point for each correct answer!`
  String get howToPlayDescription {
    return Intl.message(
      'Listen to the letter and find the matching fish. Tap on the correct fish. Earn a point for each correct answer!',
      name: 'howToPlayDescription',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get okButton {
    return Intl.message(
      'OK',
      name: 'okButton',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Correct!`
  String get correctAnswer {
    return Intl.message(
      '🎉 Correct!',
      name: 'correctAnswer',
      desc: '',
      args: [],
    );
  }

  /// `❌ Wrong! The correct letter is: {letter}`
  String wrongAnswer(Object letter) {
    return Intl.message(
      '❌ Wrong! The correct letter is: $letter',
      name: 'wrongAnswer',
      desc: '',
      args: [letter],
    );
  }

  /// `🎉 Great job! Your score: {score} out of {total}`
  String greatJob(Object score, Object total) {
    return Intl.message(
      '🎉 Great job! Your score: $score out of $total',
      name: 'greatJob',
      desc: '',
      args: [score, total],
    );
  }

  /// `😊 Good try! Your score: {score} out of {total}`
  String tryAgain2(Object score, Object total) {
    return Intl.message(
      '😊 Good try! Your score: $score out of $total',
      name: 'tryAgain2',
      desc: '',
      args: [score, total],
    );
  }

  /// `Listen`
  String get listen {
    return Intl.message(
      'Listen',
      name: 'listen',
      desc: '',
      args: [],
    );
  }

  /// `📝 Trace this letter: {letter}`
  String traceThisLetter(Object letter) {
    return Intl.message(
      '📝 Trace this letter: $letter',
      name: 'traceThisLetter',
      desc: '',
      args: [letter],
    );
  }

  /// `✅ Finish Tracing`
  String get finishTracing {
    return Intl.message(
      '✅ Finish Tracing',
      name: 'finishTracing',
      desc: '',
      args: [],
    );
  }

  /// `🎉 You've completed all letters!`
  String get completedAllLetters {
    return Intl.message(
      '🎉 You\'ve completed all letters!',
      name: 'completedAllLetters',
      desc: '',
      args: [],
    );
  }

  /// `👏 Well done! You traced all 28 Arabic letters!`
  String get encouragementMessage {
    return Intl.message(
      '👏 Well done! You traced all 28 Arabic letters!',
      name: 'encouragementMessage',
      desc: '',
      args: [],
    );
  }

  /// `📚 How to Trace`
  String get howToTrace {
    return Intl.message(
      '📚 How to Trace',
      name: 'howToTrace',
      desc: '',
      args: [],
    );
  }

  /// `1. Trace the letter with your finger.\n2. Try to stay on the shape.\n3. Press Done when finished.`
  String get instructions {
    return Intl.message(
      '1. Trace the letter with your finger.\n2. Try to stay on the shape.\n3. Press Done when finished.',
      name: 'instructions',
      desc: '',
      args: [],
    );
  }

  /// `Got it!`
  String get gotIt {
    return Intl.message(
      'Got it!',
      name: 'gotIt',
      desc: '',
      args: [],
    );
  }

  /// `✅ Done`
  String get done {
    return Intl.message(
      '✅ Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `🧹 Clear`
  String get clear {
    return Intl.message(
      '🧹 Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `✍️ Trace the letter`
  String get traceTitle {
    return Intl.message(
      '✍️ Trace the letter',
      name: 'traceTitle',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Great job!`
  String get greatJob2 {
    return Intl.message(
      '🎉 Great job!',
      name: 'greatJob2',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message(
      'Restart',
      name: 'restart',
      desc: '',
      args: [],
    );
  }

  /// `❌ Try Again`
  String get tryAgain3 {
    return Intl.message(
      '❌ Try Again',
      name: 'tryAgain3',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Well done! ✅`
  String get wellDone {
    return Intl.message(
      'Well done! ✅',
      name: 'wellDone',
      desc: '',
      args: [],
    );
  }

  /// `You traced the letter correctly!`
  String get youTracedCorrectly {
    return Intl.message(
      'You traced the letter correctly!',
      name: 'youTracedCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Spelling Game`
  String get spellingGame {
    return Intl.message(
      'Spelling Game',
      name: 'spellingGame',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `How to Play`
  String get instructionsTitle {
    return Intl.message(
      'How to Play',
      name: 'instructionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Drag the letters into the correct order.`
  String get instruction1 {
    return Intl.message(
      'Drag the letters into the correct order.',
      name: 'instruction1',
      desc: '',
      args: [],
    );
  }

  /// `If the answer is correct, you'll get a new word.`
  String get instruction2 {
    return Intl.message(
      'If the answer is correct, you\'ll get a new word.',
      name: 'instruction2',
      desc: '',
      args: [],
    );
  }

  /// `Try to complete all words and get a high score!`
  String get instruction3 {
    return Intl.message(
      'Try to complete all words and get a high score!',
      name: 'instruction3',
      desc: '',
      args: [],
    );
  }

  /// `Months Game`
  String get wordsGame3Title {
    return Intl.message(
      'Months Game',
      name: 'wordsGame3Title',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Draw the letter "{letter}"`
  String drawLetter(Object letter) {
    return Intl.message(
      'Draw the letter "$letter"',
      name: 'drawLetter',
      desc: '',
      args: [letter],
    );
  }

  /// `Touch and draw anywhere on the canvas`
  String get drawInstruction {
    return Intl.message(
      'Touch and draw anywhere on the canvas',
      name: 'drawInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Strokes: {count}`
  String strokeCount(Object count) {
    return Intl.message(
      'Strokes: $count',
      name: 'strokeCount',
      desc: '',
      args: [count],
    );
  }

  /// `Points: {count}`
  String pointCount(Object count) {
    return Intl.message(
      'Points: $count',
      name: 'pointCount',
      desc: '',
      args: [count],
    );
  }

  /// `🎮 Game Over`
  String get gameOverTitle {
    return Intl.message(
      '🎮 Game Over',
      name: 'gameOverTitle',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Great job! You're doing amazing!`
  String get greatJobMotivation {
    return Intl.message(
      '🎉 Great job! You\'re doing amazing!',
      name: 'greatJobMotivation',
      desc: '',
      args: [],
    );
  }

  /// `💪 Keep going! You can do it!`
  String get tryAgainMotivation {
    return Intl.message(
      '💪 Keep going! You can do it!',
      name: 'tryAgainMotivation',
      desc: '',
      args: [],
    );
  }

  /// `Well done! 🎉`
  String get correctFeedback {
    return Intl.message(
      'Well done! 🎉',
      name: 'correctFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get wrongFeedback {
    return Intl.message(
      'Try again',
      name: 'wrongFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Round`
  String get roundLabel2 {
    return Intl.message(
      'Round',
      name: 'roundLabel2',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get timeLabel {
    return Intl.message(
      'Time',
      name: 'timeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `Game Over!`
  String get gameFinished {
    return Intl.message(
      'Game Over!',
      name: 'gameFinished',
      desc: '',
      args: [],
    );
  }

  /// `Information about Training`
  String get info {
    return Intl.message(
      'Information about Training',
      name: 'info',
      desc: '',
      args: [],
    );
  }

  /// `Each question has 5 seconds to answer.`
  String get instructionTimer {
    return Intl.message(
      'Each question has 5 seconds to answer.',
      name: 'instructionTimer',
      desc: '',
      args: [],
    );
  }

  /// `Look carefully at the direction shape and choose the correct sentence.`
  String get instructionLookCarefully {
    return Intl.message(
      'Look carefully at the direction shape and choose the correct sentence.',
      name: 'instructionLookCarefully',
      desc: '',
      args: [],
    );
  }

  /// `After each question, the correct answer will be shown.`
  String get instructionAnswerShown {
    return Intl.message(
      'After each question, the correct answer will be shown.',
      name: 'instructionAnswerShown',
      desc: '',
      args: [],
    );
  }

  /// `Each question has 5 seconds to answer. Look carefully at the direction shape and choose the correct sentence. After each question, the correct answer will be shown.`
  String get ttsInstructions {
    return Intl.message(
      'Each question has 5 seconds to answer. Look carefully at the direction shape and choose the correct sentence. After each question, the correct answer will be shown.',
      name: 'ttsInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Start Exercise`
  String get startExercise {
    return Intl.message(
      'Start Exercise',
      name: 'startExercise',
      desc: '',
      args: [],
    );
  }

  /// `Directions`
  String get directions {
    return Intl.message(
      'Directions',
      name: 'directions',
      desc: '',
      args: [],
    );
  }

  /// `Tap the arrow to hear the direction`
  String get tapArrowToHear {
    return Intl.message(
      'Tap the arrow to hear the direction',
      name: 'tapArrowToHear',
      desc: '',
      args: [],
    );
  }

  /// `Direction Exercise`
  String get directionExerciseTitle {
    return Intl.message(
      'Direction Exercise',
      name: 'directionExerciseTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} seconds`
  String seconds(Object count) {
    return Intl.message(
      '$count seconds',
      name: 'seconds',
      desc: '',
      args: [count],
    );
  }

  /// `Question {current} / {total}`
  String questionProgress(Object current, Object total) {
    return Intl.message(
      'Question $current / $total',
      name: 'questionProgress',
      desc: '',
      args: [current, total],
    );
  }

  /// `What is the direction?`
  String get whatIsDirection {
    return Intl.message(
      'What is the direction?',
      name: 'whatIsDirection',
      desc: '',
      args: [],
    );
  }

  /// `Listen again ({remaining} attempts left)`
  String listenAgain(Object remaining) {
    return Intl.message(
      'Listen again ($remaining attempts left)',
      name: 'listenAgain',
      desc: '',
      args: [remaining],
    );
  }

  /// `Correct! ✅`
  String get correct {
    return Intl.message(
      'Correct! ✅',
      name: 'correct',
      desc: '',
      args: [],
    );
  }

  /// `Wrong! ❌`
  String get incorrect {
    return Intl.message(
      'Wrong! ❌',
      name: 'incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Correct answer: {answer}`
  String correctAnswerIs(Object answer) {
    return Intl.message(
      'Correct answer: $answer',
      name: 'correctAnswerIs',
      desc: '',
      args: [answer],
    );
  }

  /// `Try again! 💪`
  String get tryAgainEncouragement {
    return Intl.message(
      'Try again! 💪',
      name: 'tryAgainEncouragement',
      desc: '',
      args: [],
    );
  }

  /// `Excellent! 🎉`
  String get excellent {
    return Intl.message(
      'Excellent! 🎉',
      name: 'excellent',
      desc: '',
      args: [],
    );
  }

  /// `Bravo! 👏`
  String get bravo {
    return Intl.message(
      'Bravo! 👏',
      name: 'bravo',
      desc: '',
      args: [],
    );
  }

  /// `Amazing! 😎`
  String get amazing {
    return Intl.message(
      'Amazing! 😎',
      name: 'amazing',
      desc: '',
      args: [],
    );
  }

  /// `Direction Game`
  String get gameName {
    return Intl.message(
      'Direction Game',
      name: 'gameName',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Information`
  String get exerciseInfoTitle {
    return Intl.message(
      'Exercise Information',
      name: 'exerciseInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Each question has 8 seconds to answer.`
  String get timerInfo {
    return Intl.message(
      'Each question has 8 seconds to answer.',
      name: 'timerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Drag the image to the correct direction.`
  String get dragInfo {
    return Intl.message(
      'Drag the image to the correct direction.',
      name: 'dragInfo',
      desc: '',
      args: [],
    );
  }

  /// `After each question, the correct direction will be shown.`
  String get correctDirectionInfo {
    return Intl.message(
      'After each question, the correct direction will be shown.',
      name: 'correctDirectionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Directions`
  String get directionsTitle {
    return Intl.message(
      'Directions',
      name: 'directionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap the arrow to hear the direction`
  String get tapToHearDirection {
    return Intl.message(
      'Tap the arrow to hear the direction',
      name: 'tapToHearDirection',
      desc: '',
      args: [],
    );
  }

  /// `The direction is {direction}`
  String speakDirectionTemplate(Object direction) {
    return Intl.message(
      'The direction is $direction',
      name: 'speakDirectionTemplate',
      desc: '',
      args: [direction],
    );
  }

  /// `Each question has 8 seconds to answer. Drag the image to the correct direction. After each question, the correct direction will be shown.`
  String get instructionSpeech {
    return Intl.message(
      'Each question has 8 seconds to answer. Drag the image to the correct direction. After each question, the correct direction will be shown.',
      name: 'instructionSpeech',
      desc: '',
      args: [],
    );
  }

  /// `Return`
  String get returnBack {
    return Intl.message(
      'Return',
      name: 'returnBack',
      desc: '',
      args: [],
    );
  }

  /// `Don't worry, try again`
  String get dontWorryTryAgain {
    return Intl.message(
      'Don\'t worry, try again',
      name: 'dontWorryTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `You're trying hard, that's great`
  String get tryingHardGreat {
    return Intl.message(
      'You\'re trying hard, that\'s great',
      name: 'tryingHardGreat',
      desc: '',
      args: [],
    );
  }

  /// `Trying is the first step`
  String get tryingIsFirstStep {
    return Intl.message(
      'Trying is the first step',
      name: 'tryingIsFirstStep',
      desc: '',
      args: [],
    );
  }

  /// `Every try makes you stronger`
  String get everyTryMakesStronger {
    return Intl.message(
      'Every try makes you stronger',
      name: 'everyTryMakesStronger',
      desc: '',
      args: [],
    );
  }

  /// `Don't give up, learning takes time`
  String get dontGiveUpLearning {
    return Intl.message(
      'Don\'t give up, learning takes time',
      name: 'dontGiveUpLearning',
      desc: '',
      args: [],
    );
  }

  /// `Learning needs patience`
  String get learningNeedsPatience {
    return Intl.message(
      'Learning needs patience',
      name: 'learningNeedsPatience',
      desc: '',
      args: [],
    );
  }

  /// `Keep trying, you're progressing`
  String get keepTryingProgressing {
    return Intl.message(
      'Keep trying, you\'re progressing',
      name: 'keepTryingProgressing',
      desc: '',
      args: [],
    );
  }

  /// `Very great`
  String get veryGreat {
    return Intl.message(
      'Very great',
      name: 'veryGreat',
      desc: '',
      args: [],
    );
  }

  /// `Excellent work`
  String get excellentWork {
    return Intl.message(
      'Excellent work',
      name: 'excellentWork',
      desc: '',
      args: [],
    );
  }

  /// `You're very smart`
  String get verySmart {
    return Intl.message(
      'You\'re very smart',
      name: 'verySmart',
      desc: '',
      args: [],
    );
  }

  /// `Keep progressing`
  String get keepProgressing {
    return Intl.message(
      'Keep progressing',
      name: 'keepProgressing',
      desc: '',
      args: [],
    );
  }

  /// `Up`
  String get up {
    return Intl.message(
      'Up',
      name: 'up',
      desc: '',
      args: [],
    );
  }

  /// `Down`
  String get down {
    return Intl.message(
      'Down',
      name: 'down',
      desc: '',
      args: [],
    );
  }

  /// `Right`
  String get right {
    return Intl.message(
      'Right',
      name: 'right',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get left {
    return Intl.message(
      'Left',
      name: 'left',
      desc: '',
      args: [],
    );
  }

  /// `Up Right`
  String get upRight {
    return Intl.message(
      'Up Right',
      name: 'upRight',
      desc: '',
      args: [],
    );
  }

  /// `Down Right`
  String get downRight {
    return Intl.message(
      'Down Right',
      name: 'downRight',
      desc: '',
      args: [],
    );
  }

  /// `Up Left`
  String get upLeft {
    return Intl.message(
      'Up Left',
      name: 'upLeft',
      desc: '',
      args: [],
    );
  }

  /// `Down Left`
  String get downLeft {
    return Intl.message(
      'Down Left',
      name: 'downLeft',
      desc: '',
      args: [],
    );
  }

  /// `Cat`
  String get cat {
    return Intl.message(
      'Cat',
      name: 'cat',
      desc: '',
      args: [],
    );
  }

  /// `Apple`
  String get apple {
    return Intl.message(
      'Apple',
      name: 'apple',
      desc: '',
      args: [],
    );
  }

  /// `Car`
  String get car {
    return Intl.message(
      'Car',
      name: 'car',
      desc: '',
      args: [],
    );
  }

  /// `Book`
  String get book {
    return Intl.message(
      'Book',
      name: 'book',
      desc: '',
      args: [],
    );
  }

  /// `Ball`
  String get ball {
    return Intl.message(
      'Ball',
      name: 'ball',
      desc: '',
      args: [],
    );
  }

  /// `Drag the image to the correct direction`
  String get dragImageToCorrectDirection {
    return Intl.message(
      'Drag the image to the correct direction',
      name: 'dragImageToCorrectDirection',
      desc: '',
      args: [],
    );
  }

  /// `The correct direction is {direction}`
  String correctDirectionIs(Object direction) {
    return Intl.message(
      'The correct direction is $direction',
      name: 'correctDirectionIs',
      desc: '',
      args: [direction],
    );
  }

  /// `Exercise Finished`
  String get exerciseFinished {
    return Intl.message(
      'Exercise Finished',
      name: 'exerciseFinished',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Completed`
  String get exerciseCompleted {
    return Intl.message(
      'Exercise Completed',
      name: 'exerciseCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Final Score: {score} out of {total}`
  String finalScore(Object score, Object total) {
    return Intl.message(
      'Final Score: $score out of $total',
      name: 'finalScore',
      desc: '',
      args: [score, total],
    );
  }

  /// `Place {item} in {direction} direction`
  String placeImageInDirection(Object item, Object direction) {
    return Intl.message(
      'Place $item in $direction direction',
      name: 'placeImageInDirection',
      desc: '',
      args: [item, direction],
    );
  }

  /// `هل تريد الخروج من التمرين؟`
  String get exitExerciseQuestion {
    return Intl.message(
      'هل تريد الخروج من التمرين؟',
      name: 'exitExerciseQuestion',
      desc: '',
      args: [],
    );
  }

  /// `سيتم فقدان تقدمك`
  String get progressWillBeLost {
    return Intl.message(
      'سيتم فقدان تقدمك',
      name: 'progressWillBeLost',
      desc: '',
      args: [],
    );
  }

  /// `{seconds} ثواني متبقية`
  String secondsRemaining(Object seconds) {
    return Intl.message(
      '$seconds ثواني متبقية',
      name: 'secondsRemaining',
      desc: '',
      args: [seconds],
    );
  }

  /// `اسحب {item} إلى اتجاه {direction}`
  String dragImageToDirection(Object item, Object direction) {
    return Intl.message(
      'اسحب $item إلى اتجاه $direction',
      name: 'dragImageToDirection',
      desc: '',
      args: [item, direction],
    );
  }

  /// `Helpful tips for learning`
  String get helpful_tips {
    return Intl.message(
      'Helpful tips for learning',
      name: 'helpful_tips',
      desc: '',
      args: [],
    );
  }

  /// `Manage your learners`
  String get manage_learners {
    return Intl.message(
      'Manage your learners',
      name: 'manage_learners',
      desc: '',
      args: [],
    );
  }

  /// `Add new vocabulary`
  String get add_vocabulary {
    return Intl.message(
      'Add new vocabulary',
      name: 'add_vocabulary',
      desc: '',
      args: [],
    );
  }

  /// `Track learning progress`
  String get track_progress {
    return Intl.message(
      'Track learning progress',
      name: 'track_progress',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get explore {
    return Intl.message(
      'Explore',
      name: 'explore',
      desc: '',
      args: [],
    );
  }

  /// `Search for activities...`
  String get search_hint {
    return Intl.message(
      'Search for activities...',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Recent Activity`
  String get recent_activity {
    return Intl.message(
      'Recent Activity',
      name: 'recent_activity',
      desc: '',
      args: [],
    );
  }

  /// `Great Progress!`
  String get great_progress {
    return Intl.message(
      'Great Progress!',
      name: 'great_progress',
      desc: '',
      args: [],
    );
  }

  /// `Your learners completed {count} activities today`
  String learners_completed_activities(Object count) {
    return Intl.message(
      'Your learners completed $count activities today',
      name: 'learners_completed_activities',
      desc: '',
      args: [count],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get tips_title {
    return Intl.message(
      'Tips',
      name: 'tips_title',
      desc: '',
      args: [],
    );
  }

  /// `Track Learning Progress`
  String get track_learning_progress {
    return Intl.message(
      'Track Learning Progress',
      name: 'track_learning_progress',
      desc: '',
      args: [],
    );
  }

  /// `Monitor daily learning activities`
  String get monitor_daily_activities {
    return Intl.message(
      'Monitor daily learning activities',
      name: 'monitor_daily_activities',
      desc: '',
      args: [],
    );
  }

  /// `Progress Summary`
  String get progress_summary {
    return Intl.message(
      'Progress Summary',
      name: 'progress_summary',
      desc: '',
      args: [],
    );
  }

  /// `No learning activities recorded for this day`
  String get no_learning_activities {
    return Intl.message(
      'No learning activities recorded for this day',
      name: 'no_learning_activities',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get stat_total {
    return Intl.message(
      'Total',
      name: 'stat_total',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get stat_correct {
    return Intl.message(
      'Correct',
      name: 'stat_correct',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect`
  String get stat_incorrect {
    return Intl.message(
      'Incorrect',
      name: 'stat_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Breakdown`
  String get exercise_breakdown {
    return Intl.message(
      'Exercise Breakdown',
      name: 'exercise_breakdown',
      desc: '',
      args: [],
    );
  }

  /// `Letters`
  String get label_letters {
    return Intl.message(
      'Letters',
      name: 'label_letters',
      desc: '',
      args: [],
    );
  }

  /// `Words`
  String get label_words {
    return Intl.message(
      'Words',
      name: 'label_words',
      desc: '',
      args: [],
    );
  }

  /// `Sentences`
  String get label_sentences {
    return Intl.message(
      'Sentences',
      name: 'label_sentences',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get label_games {
    return Intl.message(
      'Games',
      name: 'label_games',
      desc: '',
      args: [],
    );
  }

  /// `Game Summary`
  String get game_summary {
    return Intl.message(
      'Game Summary',
      name: 'game_summary',
      desc: '',
      args: [],
    );
  }

  /// `game sessions`
  String get game_sessions {
    return Intl.message(
      'game sessions',
      name: 'game_sessions',
      desc: '',
      args: [],
    );
  }

  /// `total attempts`
  String get total_attempts {
    return Intl.message(
      'total attempts',
      name: 'total_attempts',
      desc: '',
      args: [],
    );
  }

  /// `Quest Complete`
  String get quest_complete {
    return Intl.message(
      'Quest Complete',
      name: 'quest_complete',
      desc: '',
      args: [],
    );
  }

  /// `Quest Pending`
  String get quest_pending {
    return Intl.message(
      'Quest Pending',
      name: 'quest_pending',
      desc: '',
      args: [],
    );
  }

  /// `Award Won`
  String get award_won {
    return Intl.message(
      'Award Won',
      name: 'award_won',
      desc: '',
      args: [],
    );
  }

  /// `No Award`
  String get no_award {
    return Intl.message(
      'No Award',
      name: 'no_award',
      desc: '',
      args: [],
    );
  }

  /// `Learner Details`
  String get learner_details {
    return Intl.message(
      'Learner Details',
      name: 'learner_details',
      desc: '',
      args: [],
    );
  }

  /// `No learner data available.`
  String get no_learner_data_available {
    return Intl.message(
      'No learner data available.',
      name: 'no_learner_data_available',
      desc: '',
      args: [],
    );
  }

  /// `Learner Members`
  String get parentNavBarLearnerMembers {
    return Intl.message(
      'Learner Members',
      name: 'parentNavBarLearnerMembers',
      desc: '',
      args: [],
    );
  }

  /// `Learners Progress`
  String get parentNavBarLearnersProgress {
    return Intl.message(
      'Learners Progress',
      name: 'parentNavBarLearnersProgress',
      desc: '',
      args: [],
    );
  }

  /// `Choose Language`
  String get parentNavBarChooseLanguage {
    return Intl.message(
      'Choose Language',
      name: 'parentNavBarChooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get parentNavBarEnglish {
    return Intl.message(
      'English',
      name: 'parentNavBarEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get parentNavBarArabic {
    return Intl.message(
      'Arabic',
      name: 'parentNavBarArabic',
      desc: '',
      args: [],
    );
  }

  /// `Logout Confirmation`
  String get parentNavBarLogoutConfirmation {
    return Intl.message(
      'Logout Confirmation',
      name: 'parentNavBarLogoutConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get parentNavBarLogoutPrompt {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'parentNavBarLogoutPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Learning App v2.0`
  String get parentNavBarFooterVersion {
    return Intl.message(
      'Learning App v2.0',
      name: 'parentNavBarFooterVersion',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get parentNavBarProfile {
    return Intl.message(
      'Profile',
      name: 'parentNavBarProfile',
      desc: '',
      args: [],
    );
  }

  /// `Improvement Suggestions`
  String get improvementSuggestions {
    return Intl.message(
      'Improvement Suggestions',
      name: 'improvementSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `Story {current} of {total}`
  String storyCounter(Object current, Object total) {
    return Intl.message(
      'Story $current of $total',
      name: 'storyCounter',
      desc: '',
      args: [current, total],
    );
  }

  /// `Story`
  String get story {
    return Intl.message(
      'Story',
      name: 'story',
      desc: '',
      args: [],
    );
  }

  /// `Write Your Summary Here`
  String get writeSummaryHere {
    return Intl.message(
      'Write Your Summary Here',
      name: 'writeSummaryHere',
      desc: '',
      args: [],
    );
  }

  /// `Write a summary of the story you read...`
  String get summaryHint {
    return Intl.message(
      'Write a summary of the story you read...',
      name: 'summaryHint',
      desc: '',
      args: [],
    );
  }

  /// `Checking...`
  String get checking {
    return Intl.message(
      'Checking...',
      name: 'checking',
      desc: '',
      args: [],
    );
  }

  /// `Check Summary`
  String get checkSummary {
    return Intl.message(
      'Check Summary',
      name: 'checkSummary',
      desc: '',
      args: [],
    );
  }

  /// `Story Summarizer Game`
  String get storySummarizerGame {
    return Intl.message(
      'Story Summarizer Game',
      name: 'storySummarizerGame',
      desc: '',
      args: [],
    );
  }

  /// `Level 2`
  String get letterLevel2 {
    return Intl.message(
      'Level 2',
      name: 'letterLevel2',
      desc: '',
      args: [],
    );
  }

  /// `Record your voice`
  String get recordYourVoice {
    return Intl.message(
      'Record your voice',
      name: 'recordYourVoice',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message(
      'Stop',
      name: 'stop',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, try again`
  String get errorTryAgain {
    return Intl.message(
      'An error occurred, try again',
      name: 'errorTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Read Aloud`
  String get readAloud {
    return Intl.message(
      'Read Aloud',
      name: 'readAloud',
      desc: '',
      args: [],
    );
  }

  /// `Please select a gender`
  String get genderValidationError {
    return Intl.message(
      'Please select a gender',
      name: 'genderValidationError',
      desc: '',
      args: [],
    );
  }

  /// `Please select a birthdate`
  String get birthdateValidation {
    return Intl.message(
      'Please select a birthdate',
      name: 'birthdateValidation',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get usernameHint {
    return Intl.message(
      'Username',
      name: 'usernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Click here to explore your courses!`
  String get tutorialCourseTitle {
    return Intl.message(
      'Click here to explore your courses!',
      name: 'tutorialCourseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap to navigate to your course list`
  String get tutorialCourseSubtitle {
    return Intl.message(
      'Tap to navigate to your course list',
      name: 'tutorialCourseSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get tutorialSkip {
    return Intl.message(
      'Skip',
      name: 'tutorialSkip',
      desc: '',
      args: [],
    );
  }

  /// `This is your course`
  String get tutorialCourseCardTitle {
    return Intl.message(
      'This is your course',
      name: 'tutorialCourseCardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to proceed.`
  String get tutorialCourseCardDescription {
    return Intl.message(
      'Tap here to proceed.',
      name: 'tutorialCourseCardDescription',
      desc: '',
      args: [],
    );
  }

  /// `Play Button`
  String get tutorialPlayButtonTitle {
    return Intl.message(
      'Play Button',
      name: 'tutorialPlayButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap this button to start the exercise.`
  String get tutorialPlayButtonDescription {
    return Intl.message(
      'Tap this button to start the exercise.',
      name: 'tutorialPlayButtonDescription',
      desc: '',
      args: [],
    );
  }

  /// `Expand View`
  String get tutorialExpandButtonTitle {
    return Intl.message(
      'Expand View',
      name: 'tutorialExpandButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Click to see more content or details.`
  String get tutorialExpandButtonDescription {
    return Intl.message(
      'Click to see more content or details.',
      name: 'tutorialExpandButtonDescription',
      desc: '',
      args: [],
    );
  }

  /// `View Available Levels`
  String get expandLevelsTitle {
    return Intl.message(
      'View Available Levels',
      name: 'expandLevelsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap this button to explore all available levels and games for this exercise. You need to tap it to continue!`
  String get expandLevelsDescription {
    return Intl.message(
      'Tap this button to explore all available levels and games for this exercise. You need to tap it to continue!',
      name: 'expandLevelsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Course Levels`
  String get levelsSectionTitle {
    return Intl.message(
      'Course Levels',
      name: 'levelsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `These are the available levels for this course. Each level includes unique games and activities to help you learn.`
  String get levelsSectionDescription {
    return Intl.message(
      'These are the available levels for this course. Each level includes unique games and activities to help you learn.',
      name: 'levelsSectionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Games Navigation`
  String get gamesNavigationTitle {
    return Intl.message(
      'Games Navigation',
      name: 'gamesNavigationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap any game chip to go directly to that game within the course.`
  String get gamesNavigationDescription {
    return Intl.message(
      'Tap any game chip to go directly to that game within the course.',
      name: 'gamesNavigationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Main Course Navigation`
  String get mainCourseNavigationTitle {
    return Intl.message(
      'Main Course Navigation',
      name: 'mainCourseNavigationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap this play button to go to the main course page. You must tap it to complete the tutorial!`
  String get mainCourseNavigationDescription {
    return Intl.message(
      'Tap this play button to go to the main course page. You must tap it to complete the tutorial!',
      name: 'mainCourseNavigationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back! Please sign in to continue`
  String get loginSubtitle {
    return Intl.message(
      'Welcome back! Please sign in to continue',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Navigation Menu`
  String get drawerMenuTitle {
    return Intl.message(
      'Navigation Menu',
      name: 'drawerMenuTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap these Navigation Menu to open the side menu. Here you can change your language preferences and log out when needed.`
  String get drawerMenuDescription {
    return Intl.message(
      'Tap these Navigation Menu to open the side menu. Here you can change your language preferences and log out when needed.',
      name: 'drawerMenuDescription',
      desc: '',
      args: [],
    );
  }

  /// `Your Profile`
  String get profileTabTitle {
    return Intl.message(
      'Your Profile',
      name: 'profileTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to view and update your profile information. Manage your personal details and preferences.`
  String get profileTabDescription {
    return Intl.message(
      'Tap here to view and update your profile information. Manage your personal details and preferences.',
      name: 'profileTabDescription',
      desc: '',
      args: [],
    );
  }

  /// `Your Courses`
  String get coursesTabTitle {
    return Intl.message(
      'Your Courses',
      name: 'coursesTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Access all your courses here. Browse available lessons, track your progress, and continue your learning journey.`
  String get coursesTabDescription {
    return Intl.message(
      'Access all your courses here. Browse available lessons, track your progress, and continue your learning journey.',
      name: 'coursesTabDescription',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get hello {
    return Intl.message(
      'Hello',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message(
      'Birthday',
      name: 'birthday',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message(
      'Age',
      name: 'age',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInfo {
    return Intl.message(
      'Personal Information',
      name: 'personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Oops! Something went wrong`
  String get errorTitle {
    return Intl.message(
      'Oops! Something went wrong',
      name: 'errorTitle',
      desc: '',
      args: [],
    );
  }

  /// `No profile data available`
  String get noData {
    return Intl.message(
      'No profile data available',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Order the sentences correctly`
  String get orderSentencesTitle {
    return Intl.message(
      'Order the sentences correctly',
      name: 'orderSentencesTitle',
      desc: '',
      args: [],
    );
  }

  /// `round`
  String get round {
    return Intl.message(
      'round',
      name: 'round',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get of2 {
    return Intl.message(
      'of',
      name: 'of2',
      desc: '',
      args: [],
    );
  }

  /// `Correct Answer!`
  String get correctAnswer2 {
    return Intl.message(
      'Correct Answer!',
      name: 'correctAnswer2',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Answer`
  String get wrongAnswer2 {
    return Intl.message(
      'Wrong Answer',
      name: 'wrongAnswer2',
      desc: '',
      args: [],
    );
  }

  /// `Points`
  String get points {
    return Intl.message(
      'Points',
      name: 'points',
      desc: '',
      args: [],
    );
  }

  /// `End Game`
  String get endGame {
    return Intl.message(
      'End Game',
      name: 'endGame',
      desc: '',
      args: [],
    );
  }

  /// `Next Round`
  String get nextRound {
    return Intl.message(
      'Next Round',
      name: 'nextRound',
      desc: '',
      args: [],
    );
  }

  /// `Excellent! Outstanding performance!`
  String get performanceExcellent {
    return Intl.message(
      'Excellent! Outstanding performance!',
      name: 'performanceExcellent',
      desc: '',
      args: [],
    );
  }

  /// `Very good! Great job!`
  String get performanceVeryGood {
    return Intl.message(
      'Very good! Great job!',
      name: 'performanceVeryGood',
      desc: '',
      args: [],
    );
  }

  /// `Good! You can do even better!`
  String get performanceGood {
    return Intl.message(
      'Good! You can do even better!',
      name: 'performanceGood',
      desc: '',
      args: [],
    );
  }

  /// `Try again to improve your score!`
  String get performanceTryAgain {
    return Intl.message(
      'Try again to improve your score!',
      name: 'performanceTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Percentage`
  String get percentage {
    return Intl.message(
      'Percentage',
      name: 'percentage',
      desc: '',
      args: [],
    );
  }

  /// `Back to Menu`
  String get backToMenu {
    return Intl.message(
      'Back to Menu',
      name: 'backToMenu',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Sentence Ordering`
  String get sentenceOrdering {
    return Intl.message(
      'Sentence Ordering',
      name: 'sentenceOrdering',
      desc: '',
      args: [],
    );
  }

  /// `Playing...`
  String get playingNow {
    return Intl.message(
      'Playing...',
      name: 'playingNow',
      desc: '',
      args: [],
    );
  }

  /// `Reveal Sentences`
  String get revealSentences {
    return Intl.message(
      'Reveal Sentences',
      name: 'revealSentences',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Answer`
  String get confirmAnswer {
    return Intl.message(
      'Confirm Answer',
      name: 'confirmAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Drag the sentences here to arrange them`
  String get dragSentencesHint {
    return Intl.message(
      'Drag the sentences here to arrange them',
      name: 'dragSentencesHint',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `accuracy`
  String get accuracy {
    return Intl.message(
      'accuracy',
      name: 'accuracy',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to your special world\nwhere learning is fun`
  String get title1 {
    return Intl.message(
      'Welcome to your special world\nwhere learning is fun',
      name: 'title1',
      desc: '',
      args: [],
    );
  }

  /// `I'm your friend (the app). Let me take you on a daily journey of progress and growth.`
  String get desc1 {
    return Intl.message(
      'I\'m your friend (the app). Let me take you on a daily journey of progress and growth.',
      name: 'desc1',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get button1 {
    return Intl.message(
      'Start',
      name: 'button1',
      desc: '',
      args: [],
    );
  }

  /// `Together, we will learn to read\nand write Arabic properly`
  String get title2 {
    return Intl.message(
      'Together, we will learn to read\nand write Arabic properly',
      name: 'title2',
      desc: '',
      args: [],
    );
  }

  /// `It will be a fun journey, step by step, until you become an expert.`
  String get desc2 {
    return Intl.message(
      'It will be a fun journey, step by step, until you become an expert.',
      name: 'desc2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get button2 {
    return Intl.message(
      'Continue',
      name: 'button2',
      desc: '',
      args: [],
    );
  }

  /// `Don't fear trying,\nkeep going until you break the fear barrier`
  String get title3 {
    return Intl.message(
      'Don\'t fear trying,\nkeep going until you break the fear barrier',
      name: 'title3',
      desc: '',
      args: [],
    );
  }

  /// `Nothing can stop you.`
  String get desc3 {
    return Intl.message(
      'Nothing can stop you.',
      name: 'desc3',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get submitbutton {
    return Intl.message(
      'Done',
      name: 'submitbutton',
      desc: '',
      args: [],
    );
  }

  /// `How would you like to register?`
  String get introTitle {
    return Intl.message(
      'How would you like to register?',
      name: 'introTitle',
      desc: '',
      args: [],
    );
  }

  /// `Register for someone you care about`
  String get guardianTitle {
    return Intl.message(
      'Register for someone you care about',
      name: 'guardianTitle',
      desc: '',
      args: [],
    );
  }

  /// `Registering as a guardian allows you to track and follow the progress of your loved ones, whether they are your children, students, or anyone under your responsibility.`
  String get guardianDescription {
    return Intl.message(
      'Registering as a guardian allows you to track and follow the progress of your loved ones, whether they are your children, students, or anyone under your responsibility.',
      name: 'guardianDescription',
      desc: '',
      args: [],
    );
  }

  /// `Register for yourself`
  String get userTitle {
    return Intl.message(
      'Register for yourself',
      name: 'userTitle',
      desc: '',
      args: [],
    );
  }

  /// `If you are older than 12, you can now easily register for yourself by clicking the user start button.`
  String get userDescription {
    return Intl.message(
      'If you are older than 12, you can now easily register for yourself by clicking the user start button.',
      name: 'userDescription',
      desc: '',
      args: [],
    );
  }

  /// `Guardian`
  String get guardianButton {
    return Intl.message(
      'Guardian',
      name: 'guardianButton',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get userButton {
    return Intl.message(
      'User',
      name: 'userButton',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginTitle {
    return Intl.message(
      'Login',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailHint {
    return Intl.message(
      'Email',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `●●●●●●●`
  String get passwordHint {
    return Intl.message(
      '●●●●●●●',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `or continue with`
  String get orContinueWith {
    return Intl.message(
      'or continue with',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an account?`
  String get noAccount {
    return Intl.message(
      'Don’t have an account?',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create a user account`
  String get createAccountUser {
    return Intl.message(
      'Create a user account',
      name: 'createAccountUser',
      desc: '',
      args: [],
    );
  }

  /// `Create a gaurdian account`
  String get createAccountGaurdian {
    return Intl.message(
      'Create a gaurdian account',
      name: 'createAccountGaurdian',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPasswordTitle {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your registered phone or email`
  String get forgotPasswordHint {
    return Intl.message(
      'Enter your registered phone or email',
      name: 'forgotPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `+20******336`
  String get phoneHint {
    return Intl.message(
      '+20******336',
      name: 'phoneHint',
      desc: '',
      args: [],
    );
  }

  /// `******aid@gmail.com`
  String get emailHint2 {
    return Intl.message(
      '******aid@gmail.com',
      name: 'emailHint2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code`
  String get otpPrompt {
    return Intl.message(
      'Please enter the verification code',
      name: 'otpPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePasswordTitle {
    return Intl.message(
      'Change Password',
      name: 'changePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get changepasswordHint {
    return Intl.message(
      'Password',
      name: 'changepasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPasswordHint {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Email cannot be empty`
  String get errorEmptyEmail {
    return Intl.message(
      'Email cannot be empty',
      name: 'errorEmptyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get errorEmptyPassword {
    return Intl.message(
      'Password cannot be empty',
      name: 'errorEmptyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login successful`
  String get successLogin {
    return Intl.message(
      'Login successful',
      name: 'successLogin',
      desc: '',
      args: [],
    );
  }

  /// `Invalid username or password. Please try again.`
  String get invalidCredentials {
    return Intl.message(
      'Invalid username or password. Please try again.',
      name: 'invalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `spell the word`
  String get levelLabel {
    return Intl.message(
      'spell the word',
      name: 'levelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Hello {name}`
  String greeting(Object name) {
    return Intl.message(
      'Hello $name',
      name: 'greeting',
      desc: 'Greeting for the user with their name',
      args: [name],
    );
  }

  /// `Don’t worry, it’s okay`
  String get dontWorry {
    return Intl.message(
      'Don’t worry, it’s okay',
      name: 'dontWorry',
      desc: '',
      args: [],
    );
  }

  /// `{count} attempts left`
  String attemptsLeft(Object count) {
    return Intl.message(
      '$count attempts left',
      name: 'attemptsLeft',
      desc: '',
      args: [count],
    );
  }

  /// `No words available at this level.`
  String get noWordsAvailable {
    return Intl.message(
      'No words available at this level.',
      name: 'noWordsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Recording time limit reached!`
  String get recordingTimeout {
    return Intl.message(
      'Recording time limit reached!',
      name: 'recordingTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Error starting recording: {error}`
  String recordingStartError(Object error) {
    return Intl.message(
      'Error starting recording: $error',
      name: 'recordingStartError',
      desc: '',
      args: [error],
    );
  }

  /// `Recording ignored`
  String get ignoredRecording {
    return Intl.message(
      'Recording ignored',
      name: 'ignoredRecording',
      desc: '',
      args: [],
    );
  }

  /// `Processing your recording...`
  String get processingRecording {
    return Intl.message(
      'Processing your recording...',
      name: 'processingRecording',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while processing`
  String get processingError {
    return Intl.message(
      'An error occurred while processing',
      name: 'processingError',
      desc: '',
      args: [],
    );
  }

  /// `No attempts left! Moving to the next word...`
  String get outOfTries {
    return Intl.message(
      'No attempts left! Moving to the next word...',
      name: 'outOfTries',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get nextButton {
    return Intl.message(
      'Next',
      name: 'nextButton',
      desc: '',
      args: [],
    );
  }

  /// `Transcript`
  String get transcriptLabel {
    return Intl.message(
      'Transcript',
      name: 'transcriptLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String recordingError(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'recordingError',
      desc: '',
      args: [error],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Analyzing...`
  String get feedbackWidgetAnalyzing {
    return Intl.message(
      'Analyzing...',
      name: 'feedbackWidgetAnalyzing',
      desc: '',
      args: [],
    );
  }

  /// `{percent}% completed`
  String progressCompleted(Object percent) {
    return Intl.message(
      '$percent% completed',
      name: 'progressCompleted',
      desc: 'Shows how much progress has been completed',
      args: [percent],
    );
  }

  /// `{points} pts`
  String progressPoints(Object points) {
    return Intl.message(
      '$points pts',
      name: 'progressPoints',
      desc: 'Shows how many points or lessons completed',
      args: [points],
    );
  }

  /// `Progress`
  String get exerciseProgressLabel {
    return Intl.message(
      'Progress',
      name: 'exerciseProgressLabel',
      desc: 'Label for progress bar',
      args: [],
    );
  }

  /// `{percent}%`
  String exerciseProgressPercent(Object percent) {
    return Intl.message(
      '$percent%',
      name: 'exerciseProgressPercent',
      desc: 'Format string for progress percentage',
      args: [percent],
    );
  }

  /// `Hello,`
  String get helloLabel {
    return Intl.message(
      'Hello,',
      name: 'helloLabel',
      desc: '',
      args: [],
    );
  }

  /// `Search courses...`
  String get searchCoursesHint {
    return Intl.message(
      'Search courses...',
      name: 'searchCoursesHint',
      desc: '',
      args: [],
    );
  }

  /// `Continue Learning`
  String get continueLearning {
    return Intl.message(
      'Continue Learning',
      name: 'continueLearning',
      desc: '',
      args: [],
    );
  }

  /// `Available Exercises`
  String get availableExercises {
    return Intl.message(
      'Available Exercises',
      name: 'availableExercises',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message(
      'See All',
      name: 'seeAll',
      desc: '',
      args: [],
    );
  }

  /// `No exercises available`
  String get noExercisesAvailable {
    return Intl.message(
      'No exercises available',
      name: 'noExercisesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get bottomNavHome {
    return Intl.message(
      'Home',
      name: 'bottomNavHome',
      desc: '',
      args: [],
    );
  }

  /// `Courses`
  String get bottomNavCourses {
    return Intl.message(
      'Courses',
      name: 'bottomNavCourses',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get bottomNavProfile {
    return Intl.message(
      'Profile',
      name: 'bottomNavProfile',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get bottomNavMenu {
    return Intl.message(
      'Menu',
      name: 'bottomNavMenu',
      desc: '',
      args: [],
    );
  }

  /// `Levels`
  String get levels {
    return Intl.message(
      'Levels',
      name: 'levels',
      desc: '',
      args: [],
    );
  }

  /// `Level`
  String get level {
    return Intl.message(
      'Level',
      name: 'level',
      desc: '',
      args: [],
    );
  }

  /// `Select a level to start playing`
  String get selectLevelToStart {
    return Intl.message(
      'Select a level to start playing',
      name: 'selectLevelToStart',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get games {
    return Intl.message(
      'Games',
      name: 'games',
      desc: '',
      args: [],
    );
  }

  /// `Error loading levels`
  String get errorLoadingLevels {
    return Intl.message(
      'Error loading levels',
      name: 'errorLoadingLevels',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `No levels available for this exercise`
  String get noLevelsAvailable {
    return Intl.message(
      'No levels available for this exercise',
      name: 'noLevelsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Select a game to start playing`
  String get selectGameToPlay {
    return Intl.message(
      'Select a game to start playing',
      name: 'selectGameToPlay',
      desc: '',
      args: [],
    );
  }

  /// `No games available for this level`
  String get noGamesAvailable {
    return Intl.message(
      'No games available for this level',
      name: 'noGamesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Play Now`
  String get playGame {
    return Intl.message(
      'Play Now',
      name: 'playGame',
      desc: '',
      args: [],
    );
  }

  /// `Order the Months`
  String get monthsOrderTitle {
    return Intl.message(
      'Order the Months',
      name: 'monthsOrderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Order {count} months of the year`
  String monthsOrderHeader(Object count) {
    return Intl.message(
      'Order $count months of the year',
      name: 'monthsOrderHeader',
      desc: 'Header for how many months to order in the game',
      args: [count],
    );
  }

  /// `Drag the months from below and place them in the correct order`
  String get monthsOrderHelpDrag {
    return Intl.message(
      'Drag the months from below and place them in the correct order',
      name: 'monthsOrderHelpDrag',
      desc: '',
      args: [],
    );
  }

  /// `Order the months from January to the last month in the level`
  String get monthsOrderHelpOrder {
    return Intl.message(
      'Order the months from January to the last month in the level',
      name: 'monthsOrderHelpOrder',
      desc: '',
      args: [],
    );
  }

  /// `Tap the month to hear its name`
  String get monthsOrderHelpListen {
    return Intl.message(
      'Tap the month to hear its name',
      name: 'monthsOrderHelpListen',
      desc: '',
      args: [],
    );
  }

  /// `Tap the translate button to switch between Arabic and Levantine names`
  String get monthsOrderHelpTranslate {
    return Intl.message(
      'Tap the translate button to switch between Arabic and Levantine names',
      name: 'monthsOrderHelpTranslate',
      desc: '',
      args: [],
    );
  }

  /// `Switch month names`
  String get translateMonthsTooltip {
    return Intl.message(
      'Switch month names',
      name: 'translateMonthsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Great job! You've ordered the months correctly.`
  String get monthsOrderSuccess {
    return Intl.message(
      'Great job! You\'ve ordered the months correctly.',
      name: 'monthsOrderSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Play Again`
  String get playAgain {
    return Intl.message(
      'Play Again',
      name: 'playAgain',
      desc: '',
      args: [],
    );
  }

  /// `all`
  String get all {
    return Intl.message(
      'all',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `يناير, فبراير, مارس, أبريل, مايو, يونيو, يوليو, أغسطس, سبتمبر, أكتوبر, نوفمبر, ديسمبر`
  String get monthsOrderList {
    return Intl.message(
      'يناير, فبراير, مارس, أبريل, مايو, يونيو, يوليو, أغسطس, سبتمبر, أكتوبر, نوفمبر, ديسمبر',
      name: 'monthsOrderList',
      desc: 'Always Arabic month names for the months ordering game.',
      args: [],
    );
  }

  /// `Level {level}: Order {count} months {direction}`
  String monthsOrderLevelInstruction(
      Object level, Object count, Object direction) {
    return Intl.message(
      'Level $level: Order $count months $direction',
      name: 'monthsOrderLevelInstruction',
      desc:
          'Instruction for each level showing how many months to order and in which direction',
      args: [level, count, direction],
    );
  }

  /// `from first to last`
  String get orderAscending {
    return Intl.message(
      'from first to last',
      name: 'orderAscending',
      desc: '',
      args: [],
    );
  }

  /// `from last to first`
  String get orderDescending {
    return Intl.message(
      'from last to first',
      name: 'orderDescending',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Amazing! You've completed level {level}!`
  String levelSuccess(Object level) {
    return Intl.message(
      '🎉 Amazing! You\'ve completed level $level!',
      name: 'levelSuccess',
      desc: 'Success message when completing a level',
      args: [level],
    );
  }

  /// `Don't worry! Practice makes perfect. Try this level again!`
  String get levelFailure {
    return Intl.message(
      'Don\'t worry! Practice makes perfect. Try this level again!',
      name: 'levelFailure',
      desc: '',
      args: [],
    );
  }

  /// `Keep going! You're getting better with each try!`
  String get levelRetry {
    return Intl.message(
      'Keep going! You\'re getting better with each try!',
      name: 'levelRetry',
      desc: '',
      args: [],
    );
  }

  /// `🌟 Incredible! You've mastered all month orders!`
  String get finalLevelSuccess {
    return Intl.message(
      '🌟 Incredible! You\'ve mastered all month orders!',
      name: 'finalLevelSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Completed!`
  String get gameCompleted {
    return Intl.message(
      'Completed!',
      name: 'gameCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Order the months correctly.`
  String get orderMonthsCorrectly {
    return Intl.message(
      'Order the months correctly.',
      name: 'orderMonthsCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get learnerNavBarHome {
    return Intl.message(
      'Home',
      name: 'learnerNavBarHome',
      desc: '',
      args: [],
    );
  }

  /// `Courses`
  String get learnerNavBarCourses {
    return Intl.message(
      'Courses',
      name: 'learnerNavBarCourses',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get learnerNavBarProfile {
    return Intl.message(
      'Profile',
      name: 'learnerNavBarProfile',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get learnerNavBarMenu {
    return Intl.message(
      'Menu',
      name: 'learnerNavBarMenu',
      desc: '',
      args: [],
    );
  }

  /// `Sign out securely`
  String get logoutSubtitle {
    return Intl.message(
      'Sign out securely',
      name: 'logoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `cancel`
  String get cancelButton {
    return Intl.message(
      'cancel',
      name: 'cancelButton',
      desc: '',
      args: [],
    );
  }

  /// `Logout Confirmation`
  String get logoutConfirmationTitle {
    return Intl.message(
      'Logout Confirmation',
      name: 'logoutConfirmationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?\nYou will need to sign in again.`
  String get logoutConfirmationMessage {
    return Intl.message(
      'Are you sure you want to logout?\nYou will need to sign in again.',
      name: 'logoutConfirmationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logoutButton {
    return Intl.message(
      'Logout',
      name: 'logoutButton',
      desc: '',
      args: [],
    );
  }

  /// `Choose Language`
  String get chooseLanguageTitle {
    return Intl.message(
      'Choose Language',
      name: 'chooseLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select your preferred language`
  String get chooseLanguageSubtitle {
    return Intl.message(
      'Select your preferred language',
      name: 'chooseLanguageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get englishLanguage {
    return Intl.message(
      'English',
      name: 'englishLanguage',
      desc: '',
      args: [],
    );
  }

  /// `العربية`
  String get arabicLanguage {
    return Intl.message(
      'العربية',
      name: 'arabicLanguage',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get defaultUserName {
    return Intl.message(
      'User',
      name: 'defaultUserName',
      desc: '',
      args: [],
    );
  }

  /// `username`
  String get defaultUsername {
    return Intl.message(
      'username',
      name: 'defaultUsername',
      desc: '',
      args: [],
    );
  }

  /// `Object Detection Exercise`
  String get appTitle {
    return Intl.message(
      'Object Detection Exercise',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bring a {object}`
  String bringObject(String object) {
    return Intl.message(
      'Bring a $object',
      name: 'bringObject',
      desc: '',
      args: [object],
    );
  }

  /// `Object Detection Exercise`
  String get objectDetectionExercise {
    return Intl.message(
      'Object Detection Exercise',
      name: 'objectDetectionExercise',
      desc: '',
      args: [],
    );
  }

  /// `Point your camera at the requested object to complete the exercise`
  String get objectDetectionHint {
    return Intl.message(
      'Point your camera at the requested object to complete the exercise',
      name: 'objectDetectionHint',
      desc: '',
      args: [],
    );
  }

  /// `Point your camera at the requested object to complete the exercise`
  String get hint {
    return Intl.message(
      'Point your camera at the requested object to complete the exercise',
      name: 'hint',
      desc: '',
      args: [],
    );
  }

  /// `spoon`
  String get spoon {
    return Intl.message(
      'spoon',
      name: 'spoon',
      desc: '',
      args: [],
    );
  }

  /// `cup`
  String get cup {
    return Intl.message(
      'cup',
      name: 'cup',
      desc: '',
      args: [],
    );
  }

  /// `pen`
  String get pen {
    return Intl.message(
      'pen',
      name: 'pen',
      desc: '',
      args: [],
    );
  }

  /// `fork`
  String get fork {
    return Intl.message(
      'fork',
      name: 'fork',
      desc: '',
      args: [],
    );
  }

  /// `plate`
  String get plate {
    return Intl.message(
      'plate',
      name: 'plate',
      desc: '',
      args: [],
    );
  }

  /// `Great! Object detected!`
  String get objectDetected {
    return Intl.message(
      'Great! Object detected!',
      name: 'objectDetected',
      desc: '',
      args: [],
    );
  }

  /// `Object not detected. Keep trying!`
  String get objectNotFound {
    return Intl.message(
      'Object not detected. Keep trying!',
      name: 'objectNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Next Exercise`
  String get nextExercise {
    return Intl.message(
      'Next Exercise',
      name: 'nextExercise',
      desc: '',
      args: [],
    );
  }

  /// `Score: {score}`
  String score(int score) {
    return Intl.message(
      'Score: $score',
      name: 'score',
      desc: '',
      args: [score],
    );
  }

  /// `Loading words...`
  String get loadingWords {
    return Intl.message(
      'Loading words...',
      name: 'loadingWords',
      desc: 'Message shown while fetching words from the server',
      args: [],
    );
  }

  /// `Great job! You've completed all words!`
  String get allWordsCompleted {
    return Intl.message(
      'Great job! You\'ve completed all words!',
      name: 'allWordsCompleted',
      desc: 'Success message when user finishes all words in the exercise',
      args: [],
    );
  }

  /// `Congratulations!`
  String get congratulations {
    return Intl.message(
      'Congratulations!',
      name: 'congratulations',
      desc: 'Title for completion dialog',
      args: [],
    );
  }

  /// `You have successfully completed all words in this exercise!`
  String get completedAllWords {
    return Intl.message(
      'You have successfully completed all words in this exercise!',
      name: 'completedAllWords',
      desc: 'Message in completion dialog explaining the achievement',
      args: [],
    );
  }

  /// `Finish`
  String get finish {
    return Intl.message(
      'Finish',
      name: 'finish',
      desc: 'Button text to finish the exercise and go back',
      args: [],
    );
  }

  /// `Start Over`
  String get startOver {
    return Intl.message(
      'Start Over',
      name: 'startOver',
      desc: 'Button text to restart the exercise with the same words',
      args: [],
    );
  }

  /// `View Results`
  String get viewResults {
    return Intl.message(
      'View Results',
      name: 'viewResults',
      desc: 'Button text when all words are completed to view final results',
      args: [],
    );
  }

  /// `Locked`
  String get locked {
    return Intl.message(
      'Locked',
      name: 'locked',
      desc: 'Text shown when a game is locked',
      args: [],
    );
  }

  /// `This game is locked. Complete previous levels to unlock it.`
  String get gameLockedMessage {
    return Intl.message(
      'This game is locked. Complete previous levels to unlock it.',
      name: 'gameLockedMessage',
      desc: 'Message shown when user tries to access a locked game',
      args: [],
    );
  }

  /// `Level One - Live Camera`
  String get level_one_live_camera {
    return Intl.message(
      'Level One - Live Camera',
      name: 'level_one_live_camera',
      desc: 'Title for level one live camera screen',
      args: [],
    );
  }

  /// `New Word`
  String get new_word {
    return Intl.message(
      'New Word',
      name: 'new_word',
      desc: 'Button text for getting a new word',
      args: [],
    );
  }

  /// `Target Word`
  String get target_word {
    return Intl.message(
      'Target Word',
      name: 'target_word',
      desc: 'Label for the target word section',
      args: [],
    );
  }

  /// `Analyzing...`
  String get analyzing {
    return Intl.message(
      'Analyzing...',
      name: 'analyzing',
      desc: 'Text shown when analyzing the camera input',
      args: [],
    );
  }

  /// `Preparing Camera...`
  String get preparing_camera {
    return Intl.message(
      'Preparing Camera...',
      name: 'preparing_camera',
      desc: 'Text shown when initializing the camera',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: 'Label for the detection result',
      args: [],
    );
  }

  /// `Correct Answer! Well Done!`
  String get correct_answer {
    return Intl.message(
      'Correct Answer! Well Done!',
      name: 'correct_answer',
      desc: 'Text shown when the answer is correct',
      args: [],
    );
  }

  /// `Try Again`
  String get try_again {
    return Intl.message(
      'Try Again',
      name: 'try_again',
      desc: 'Text shown when the answer is incorrect',
      args: [],
    );
  }

  /// `Point the camera towards the target object within the red frame`
  String get point_camera_instruction {
    return Intl.message(
      'Point the camera towards the target object within the red frame',
      name: 'point_camera_instruction',
      desc: 'Instruction for pointing the camera at the target object',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: 'Status text when processing',
      args: [],
    );
  }

  /// `Ready to Capture`
  String get ready_to_capture {
    return Intl.message(
      'Ready to Capture',
      name: 'ready_to_capture',
      desc: 'Status text when ready to capture',
      args: [],
    );
  }

  /// `❌ Error reading result`
  String get errorReadingResult {
    return Intl.message(
      '❌ Error reading result',
      name: 'errorReadingResult',
      desc: '',
      args: [],
    );
  }

  /// `Well done! You've completed all the words.`
  String get congratsAllWordsCompleted {
    return Intl.message(
      'Well done! You\'ve completed all the words.',
      name: 'congratsAllWordsCompleted',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
