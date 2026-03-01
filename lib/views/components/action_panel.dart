import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';

class ActionPanel extends StatelessWidget {
  final GameController controller;
  final Player user;
  final double scale;

  const ActionPanel({
    super.key,
    required this.controller,
    required this.user,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    bool canPlay =
        state.selectedCards.isNotEmpty &&
        state.currentPlayer.id == user.id &&
        controller.canPlayCard(state.selectedCards.first);

    if (state.currentPhase == GamePhase.swap &&
        state.currentPlayer.id == user.id) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (controller.swapHandCard != null &&
                      controller.swapFaceUpCard != null)
                  ? Colors.blue
                  : const Color(0xFF1E1E1E),
              foregroundColor:
                  (controller.swapHandCard != null &&
                      controller.swapFaceUpCard != null)
                  ? Colors.white
                  : Colors.grey,
              side: BorderSide(
                color:
                    (controller.swapHandCard != null &&
                        controller.swapFaceUpCard != null)
                    ? Colors.blue
                    : Colors.grey,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 12 * scale,
              ),
            ),
            onPressed:
                (controller.swapHandCard != null &&
                    controller.swapFaceUpCard != null)
                ? () => controller.performSwap(user)
                : null,
            child: Text(
              'SWAP',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(width: 24 * scale),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.green),
              padding: EdgeInsets.symmetric(
                horizontal: 40 * scale,
                vertical: 12 * scale,
              ),
            ),
            onPressed: () => controller.finishSwapping(user),
            child: Text(
              'READY',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: const Color(0xFFf4c025),
              side: const BorderSide(color: Color(0xFFf4c025)),
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 12 * scale,
              ),
            ),
            onPressed: () => controller.pickUpPile(user),
            child: Text(
              'PICK UP',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(width: 24 * scale),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canPlay ? Colors.green : const Color(0xFF1E1E1E),
              foregroundColor: canPlay ? Colors.white : Colors.grey,
              side: BorderSide(color: canPlay ? Colors.green : Colors.grey),
              padding: EdgeInsets.symmetric(
                horizontal: 40 * scale,
                vertical: 12 * scale,
              ),
            ),
            onPressed: canPlay
                ? () => controller.playSelectedCards(user)
                : null,
            child: Text(
              'PLAY',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      );
    }
  }
}
