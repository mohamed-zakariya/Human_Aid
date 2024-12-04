import 'package:flutter/material.dart';
import 'package:mobile_app/Level1/Level1Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Level1screen();
  }
}
