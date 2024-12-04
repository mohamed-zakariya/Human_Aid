import 'package:flutter/material.dart';
import 'Level1/Level1Screen.dart';
// import 'SignUpPage/sign_up_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Level1screen(),
    );
  }
}
