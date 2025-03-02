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
  String get ParentNavBarHome {
    return Intl.message(
      'Home',
      name: 'ParentNavBarHome',
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

  /// `Confirm password must be entered`
  String get confirmPasswordRequired {
    return Intl.message(
      'Confirm password must be entered',
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

  /// `humanid@gmail.com`
  String get emailHint {
    return Intl.message(
      'humanid@gmail.com',
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
