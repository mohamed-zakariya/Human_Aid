import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/google_auth_service.dart';
import '../../generated/l10n.dart';
import '../../models/learner.dart';
import '../widgets/language_toggle_icon.dart';

class LoginScreenUser extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LoginScreenUser({super.key, required this.onLocaleChange});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

TextEditingController _usernameController = TextEditingController();
TextEditingController _passwordController = TextEditingController();


class _LoginScreenUserState extends State<LoginScreenUser> {
  void _handleGoogleSignIn(BuildContext context) async {
    final User? user = await GoogleAuthService.loginWithGoogle(); // Use GoogleAuthService
    if (user != null) {
      await _setOnboardingSeen(); // ✅ Set flag
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed")),
      );
    }
  }

  Future<void> _setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
  }

  void handleLoginUser() async{
    print("entered");

    String username = _usernameController.text;
    String password = _passwordController.text;

    print("user loged with username: $username");
    print("user loged with password: $password");

    Learner? learner = await AuthService.loginLearner(username, password);
    if (learner != null) {
      await _setOnboardingSeen(); // ✅ Set flag
      Navigator.pushReplacementNamed(context, '/Learner-Home', arguments: learner);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageToggleIcon(onLocaleChange: widget.onLocaleChange),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/image6.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                S.of(context).loginTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Email Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: S.of(context).emailHint,
                  filled: true,
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]
                  ),
                  fillColor: const Color.fromARGB(26, 108, 99, 255),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: S.of(context).passwordHint,
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400]
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(26, 108, 99, 255),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: const Icon(Icons.visibility),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    S.of(context).forgotPassword,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    handleLoginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 176, 199, 227),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: Text(S.of(context).loginButton),
                ),
              ),
              const SizedBox(height: 10),
              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(S.of(context).orContinueWith),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 10),
              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _handleGoogleSignIn(context),
                    icon: const FaIcon(FontAwesomeIcons.google),
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement Facebook login
                    },
                    icon: const FaIcon(FontAwesomeIcons.facebook),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement Apple login
                    },
                    icon: const FaIcon(FontAwesomeIcons.apple),
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Footer Text
              RichText(
                text: TextSpan(
                  text: '${S.of(context).noAccount} ',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  children: [
                    TextSpan(
                      text: S.of(context).createAccountUser,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 249, 178, 136),
                        fontSize: 20,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/signupAdult');
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}