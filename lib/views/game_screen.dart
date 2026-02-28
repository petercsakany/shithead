import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'components/card_widget.dart';
import 'components/player_zone.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => GameController(), child: const _GameScreenContent());
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent();

  void _showHistoryDialog(BuildContext context, List<String> history) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFf4c025)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 300,
            height: 400,
            child: Column(
              children: [
                const Text(
                  'MOVE HISTORY',
                  style: TextStyle(
                    color: Color(0xFFf4c025),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: history.isEmpty
                      ? const Center(
                          child: Text('No moves yet', style: TextStyle(color: Colors.white54)),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text('- ${history[index]}', style: const TextStyle(color: Colors.white70)),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf4c025),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep cyberpunk charcoal
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, controller, child) {
            final state = controller.state;
            final user = state.players.firstWhere((p) => !p.isAI);
            final aiTop = state.players.firstWhere((p) => p.name.contains('Top'));
            final aiLeft = state.players.firstWhere((p) => p.name.contains('Left'));
            final aiRight = state.players.firstWhere((p) => p.name.contains('Right'));

            return LayoutBuilder(
              builder: (context, constraints) {
                double scale = 1.0;
                if (constraints.maxHeight < 600) {
                  scale = constraints.maxHeight / 600;
                }
                if (scale < 0.5) scale = 0.5;

                return Stack(
                  children: [
                    // GAME BOARD
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top AI
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildPlayerZoneDecorated(context, aiTop, controller, isVertical: true, scale: scale),
                        ),
                        // Middle Area
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left AI
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: _buildPlayerZoneDecorated(
                                      context,
                                      aiLeft,
                                      controller,
                                      isVertical: false,
                                      scale: scale,
                                    ),
                                  ),
                                ),
                              ),
                              // Center Play Area
                              _buildCenterArea(state, scale),
                              // Right AI
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: _buildPlayerZoneDecorated(
                                      context,
                                      aiRight,
                                      controller,
                                      isVertical: false,
                                      scale: scale,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom User
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildPlayerZoneDecorated(context, user, controller, isVertical: true, scale: scale),
                        ),
                      ],
                    ),

                    // Message overlay top-left
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.latestMessage != null)
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFf4c025)),
                                  ),
                                  child: Text(
                                    state.latestMessage!,
                                    style: const TextStyle(color: Color(0xFFf4c025), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.history, color: Color(0xFFf4c025)),
                              onPressed: () => _showHistoryDialog(context, state.messageHistory),
                              tooltip: 'View History',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons at bottom right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 120.0 * scale, right: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.selectedCards.isNotEmpty && state.currentPlayer.id == user.id) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => controller.playSelectedCards(user),
                                child: const Text('PLAY SELECTED', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                            ],
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFf4c025),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => controller.pickUpPile(user),
                              child: const Text('PICK UP PILE', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: const Color(0xFFf4c025),
                                side: const BorderSide(color: Color(0xFFf4c025)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => controller.startNewGame(),
                              child: const Text('NEW GAME'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Game Over Overlay
                    if (controller.isGameOver)
                      Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'GAME OVER',
                                style: TextStyle(fontSize: 40, color: Color(0xFFf4c025), fontWeight: FontWeight.bold),
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
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCenterArea(GameState state, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Draw Pile
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DECK',
              style: TextStyle(
                color: const Color(0xFFf4c025),
                letterSpacing: 2,
                fontSize: 10 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * scale),
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Slightly offset multiple cards to mimic a pile
                if (state.deck.remaining > 2)
                  Positioned(
                    left: 2 * scale,
                    top: 2 * scale,
                    child: CardWidget(card: null, isFaceUp: false, width: 60 * scale, height: 90 * scale),
                  ),
                if (state.deck.remaining > 1)
                  Positioned(
                    left: 1 * scale,
                    top: 1 * scale,
                    child: CardWidget(card: null, isFaceUp: false, width: 60 * scale, height: 90 * scale),
                  ),
                CardWidget(card: null, isFaceUp: false, width: 60 * scale, height: 90 * scale),
              ],
            ),
            SizedBox(height: 4 * scale),
            Text(
              '${state.deck.remaining}',
              style: TextStyle(color: Colors.white54, fontSize: 14 * scale),
            ),
          ],
        ),
        SizedBox(width: 40 * scale),
        // Discard Pile
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PILE',
              style: TextStyle(
                color: const Color(0xFFf4c025),
                letterSpacing: 2,
                fontSize: 10 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * scale),
            if (state.topCard != null)
              CardWidget(card: state.topCard, isFaceUp: true, width: 60 * scale, height: 90 * scale)
            else
              Container(
                width: 60 * scale,
                height: 90 * scale,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            SizedBox(height: 4 * scale),
            Text(
              '${state.discardPile.length}',
              style: TextStyle(color: Colors.white54, fontSize: 14 * scale),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerZoneDecorated(
    BuildContext context,
    Player player,
    GameController controller, {
    required bool isVertical,
    double scale = 1.0,
  }) {
    bool isActive = player.id == controller.state.currentPlayer.id;
    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: const Color(0xFFf4c025), width: 2) : null,
        boxShadow: isActive
            ? [BoxShadow(color: const Color(0xFFf4c025).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)]
            : null,
      ),
      child: PlayerZone(
        player: player,
        isUser: !player.isAI,
        scale: scale,
        onPlayCard: isActive && !player.isAI
            ? (card) {
                controller.toggleCardSelection(player, card);
              }
            : null,
        isCardSelected: (card) => controller.state.selectedCards.contains(card),
      ),
    );
  }
}
