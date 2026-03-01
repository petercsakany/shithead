import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';

class GameDrawer extends StatelessWidget {
  const GameDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF121212),
              border: Border(
                bottom: BorderSide(color: Color(0xFFf4c025), width: 2),
              ),
            ),
            child: Center(
              child: Text(
                'SHITHEAD',
                style: TextStyle(
                  color: Color(0xFFf4c025),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          Consumer<GameController>(
            builder: (context, controller, child) {
              return ListTile(
                leading: const Icon(Icons.refresh, color: Color(0xFFf4c025)),
                title: const Text(
                  'New Game',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  controller.startNewGame();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
