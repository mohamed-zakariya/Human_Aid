import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../Services/password_reset_service.dart';
import '../../generated/l10n.dart';
import '../widgets/language_toggle_icon.dart';

class OTPVerificationScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const OTPVerificationScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    final String email = ModalRoute.of(context)!.settings.arguments as String;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 238, 190, 198)),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          LanguageToggleIcon(onLocaleChange: onLocaleChange),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/image9.png', height: 200),
            const SizedBox(height: 20),
            Text(
              S.of(context).otpPrompt,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              controller: otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 238, 190, 198)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onCompleted: (pin) => print("Entered OTP: $pin"),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final email = ModalRoute.of(context)!.settings.arguments as String;
                  final otp = otpController.text.trim();

                  if (otp.isEmpty || otp.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid 6-digit OTP.")),
                    );
                    return;
                  }

                  try {
                    print("Sending OTP: $otp for email: $email");  // Debugging line
                    String token = await PasswordResetService.verifyOTP(email, otp);
                    print("Received Token: $token");  // Debugging line

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("OTP verified successfully!")),
                    );

                    // Navigate to change password screen, passing the token
                    Navigator.pushNamed(context, '/change-password', arguments: token);
                  } catch (e) {
                    print("Error received: $e");  // Debugging line
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 238, 190, 198),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).continueButton,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
