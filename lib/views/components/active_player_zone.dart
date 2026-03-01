import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import 'player_zone.dart';

class ActivePlayerZone extends StatelessWidget {
  final Player player;
  final GameController controller;
  final bool isVertical;
  final double scale;

  const ActivePlayerZone({
    super.key,
    required this.player,
    required this.controller,
    required this.isVertical,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = player.id == controller.state.currentPlayer.id;
    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: const Color(0xFFf4c025), width: 2)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFf4c025).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: PlayerZone(
        player: player,
        isUser: !player.isAI,
        isSwapping: controller.state.currentPhase == GamePhase.swap,
        scale: scale,
        onPlayCard: isActive && !player.isAI
            ? (card) {
                controller.toggleCardSelection(player, card);
              }
            : null,
        isCardSelected: (card) {
          if (controller.state.currentPhase == GamePhase.swap) {
            return controller.swapHandCard == card ||
                controller.swapFaceUpCard == card;
          }
          return controller.state.selectedCards.contains(card);
        },
      ),
    );
  }
}
