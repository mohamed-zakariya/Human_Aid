import 'package:flutter/material.dart';

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            SizedBox(
              height: 120,
              width: 120,
              child: Image(
                image: AssetImage('assets/images/icon/LexFix.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 30),

            // Spinner
            CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
