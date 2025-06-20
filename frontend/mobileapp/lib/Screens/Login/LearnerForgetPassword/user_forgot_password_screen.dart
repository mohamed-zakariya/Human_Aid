import 'package:flutter/material.dart';
import '../../../Services/user_password_reset_service.dart';
import '../../../generated/l10n.dart';
import '../../widgets/language_toggle_icon.dart';

class UserForgotPasswordPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const UserForgotPasswordPage({super.key, required this.onLocaleChange});

  @override
  _UserForgotPasswordPageState createState() => _UserForgotPasswordPageState();
}

class _UserForgotPasswordPageState extends State<UserForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          LanguageToggleIcon(onLocaleChange: widget.onLocaleChange),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/image8.png', height: 250),
              const SizedBox(height: 30),
              Text(
                S.of(context).forgotPasswordTitle,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: S.of(context).emailHint2,
                  filled: true,
                  fillColor: const Color.fromARGB(26, 108, 99, 255),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your email.")),
                      );
                      return;
                    }

                    try {
                      String response = await UserPasswordResetService.forgotPassword(email);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
                      Navigator.pushNamed(context, '/user-otp-verification', arguments: email);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 249, 178, 136),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: Text(S.of(context).continueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}