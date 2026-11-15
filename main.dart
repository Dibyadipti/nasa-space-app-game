import 'package:flutter/material.dart';
import 'screens/tutorial_screen.dart';

void main() {
  runApp(const SpaceMissionApp());
}

class SpaceMissionApp extends StatelessWidget {
  const SpaceMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbital Architect - Space Mission Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E17),
        primaryColor: const Color(0xFF00E5FF),
        cardColor: const Color(0xFF151C2C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF6D00),
          surface: Color(0xFF151C2C),
        ),
      ),
      home: const OnboardingTutorialScreen(),
    );
  }
}
