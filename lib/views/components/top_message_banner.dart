import 'package:flutter/material.dart';

class TopMessageBanner extends StatelessWidget {
  final String message;

  const TopMessageBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFf4c025)),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFf4c025),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
