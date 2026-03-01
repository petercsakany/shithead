import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';

class GameOverOverlay extends StatelessWidget {
  final GameController controller;

  const GameOverOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.isGameOver) return const SizedBox.shrink();

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${controller.winner} WON!',
              style: const TextStyle(
                fontSize: 40,
                color: Color(0xFFf4c025),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf4c025),
                foregroundColor: Colors.black,
              ),
              onPressed: () => controller.startNewGame(),
              child: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
