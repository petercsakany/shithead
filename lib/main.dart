import 'package:flutter/material.dart';
import 'views/game_screen.dart';

void main() {
  runApp(const ShitheadGameApp());
}

class ShitheadGameApp extends StatelessWidget {
  const ShitheadGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shithead',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto', // Cyberpunk style fallback
        colorScheme: const ColorScheme.dark(primary: Color(0xFFf4c025), secondary: Color(0xFFf4c025)),
      ),
      home: const GameScreen(),
    );
  }
}
