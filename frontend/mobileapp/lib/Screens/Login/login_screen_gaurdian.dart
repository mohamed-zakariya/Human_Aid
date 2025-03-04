import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobileapp/Services/auth_service.dart';
import 'package:mobileapp/Services/google_auth_parent_service.dart';

import '../../generated/l10n.dart';
import '../../models/parent.dart';
import '../widgets/language_toggle_icon.dart';

class LoginScreenGaurdian extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LoginScreenGaurdian({super.key, required this.onLocaleChange});

  @override
  State<LoginScreenGaurdian> createState() => _LoginScreenGaurdianState();
}

class _LoginScreenGaurdianState extends State<LoginScreenGaurdian> {


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    print("entered");

    String email = _emailController.text;
    String password = _passwordController.text;

    print("user loged with username: $email");
    print("user loged with password: $password");

    Parent? parent = await AuthService.loginParent(email, password);
    if (parent != null) {
      print(parent.name);
      Navigator.pushReplacementNamed(
          context,
          '/parentHome',
          arguments: parent);
    }
    else {
      print("Enter the right username && password");
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
          LanguageToggleIcon(onLocaleChange: widget.onLocaleChange), // Reused widget
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
                  'assets/images/image7.png',
                  width: 300,
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
                controller: _emailController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400]
                  ),
                  hintText: S.of(context).emailHint,
                  filled: true,
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
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400]
                  ),
                  hintText: S.of(context).passwordHint,
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
                    handleLogin();
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
                    onPressed: () async {
                        final authService = AuthParentService();
                        final user = await authService.signInWithGoogle();
                        if (user != null) {
                          // Navigate to the home screen or save credentials
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                    icon: const FaIcon(FontAwesomeIcons.google),
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const FaIcon(FontAwesomeIcons.facebook),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
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
                      text: S.of(context).createAccountGaurdian,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 249, 178, 136),
                        fontSize: 20,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/signup1');
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

