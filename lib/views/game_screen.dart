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
                // Base scale primarily on width for portrait prioritize, with a generous max width bound
                if (constraints.maxWidth < 600) {
                  scale = constraints.maxWidth / 600;
                }
                if (scale < 0.6) scale = 0.6; // Don't shrink too much

                // (iconScale removed to fix unused variable warning)

                Widget content = Column(
                  children: [
                    // 1. Message area (Top)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            )
                          else
                            const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.history, color: Color(0xFFf4c025)),
                            onPressed: () => _showHistoryDialog(context, state.messageHistory),
                            tooltip: 'View History',
                          ),
                        ],
                      ),
                    ),

                    // 2. Top AI Player
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildPlayerZoneDecorated(context, aiTop, controller, isVertical: true, scale: scale),
                    ),

                    // 3. Middle AI Players (Left & Right side by side)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPlayerZoneDecorated(context, aiLeft, controller, isVertical: true, scale: scale),
                          _buildPlayerZoneDecorated(context, aiRight, controller, isVertical: true, scale: scale),
                        ],
                      ),
                    ),

                    // 4. Center Play Area (Deck and Discard Pile)
                    Expanded(child: Center(child: _buildCenterArea(state, scale))),

                    // 5. Bottom User and Actions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left Action Buttons (New Game / Pick Up)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                color: const Color(0xFFf4c025),
                                onPressed: () => controller.startNewGame(),
                                tooltip: 'New Game',
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                color: const Color(0xFFf4c025),
                                onPressed: () => controller.pickUpPile(user),
                                tooltip: 'Pick Up Pile',
                              ),
                            ],
                          ),
                          // User Zone
                          Expanded(
                            child: _buildPlayerZoneDecorated(context, user, controller, isVertical: true, scale: scale),
                          ),
                          // Right Action Buttons (Play Selected)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                color: (state.selectedCards.isNotEmpty && state.currentPlayer.id == user.id)
                                    ? Colors.green
                                    : Colors.grey,
                                onPressed: (state.selectedCards.isNotEmpty && state.currentPlayer.id == user.id)
                                    ? () => controller.playSelectedCards(user)
                                    : null,
                                tooltip: 'Play Selected',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                return Stack(
                  children: [
                    content,
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
        // Deck
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
                    child: CardWidget(card: null, isFaceUp: false, width: 75 * scale, height: 110 * scale),
                  ),
                if (state.deck.remaining > 1)
                  Positioned(
                    left: 1 * scale,
                    top: 1 * scale,
                    child: CardWidget(card: null, isFaceUp: false, width: 75 * scale, height: 110 * scale),
                  ),
                if (state.deck.remaining > 0)
                  CardWidget(card: null, isFaceUp: false, width: 75 * scale, height: 110 * scale)
                else
                  Container(
                    width: 75 * scale,
                    height: 110 * scale,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white10,
                    ),
                  ),
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
              'DISCARD PILE',
              style: TextStyle(
                color: const Color(0xFFf4c025),
                letterSpacing: 2,
                fontSize: 10 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * scale),
            if (state.topCard != null)
              CardWidget(card: state.topCard, isFaceUp: true, width: 75 * scale, height: 110 * scale)
            else
              Container(
                width: 75 * scale,
                height: 110 * scale,
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
    double scale = 1,
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
