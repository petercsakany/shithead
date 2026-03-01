import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import 'components/history_dialog.dart';
import 'components/game_drawer.dart';
import 'components/top_message_banner.dart';
import 'components/active_player_zone.dart';
import 'components/center_play_area.dart';
import 'components/action_panel.dart';
import 'components/game_over_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep cyberpunk charcoal
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFf4c025)),
        actions: [
          Consumer<GameController>(
            builder: (context, controller, child) {
              return IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => HistoryDialog.show(
                  context,
                  controller.state.messageHistory,
                ),
                tooltip: 'View History',
              );
            },
          ),
        ],
      ),
      drawer: const GameDrawer(),
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, controller, child) {
            final state = controller.state;
            final user = state.players.firstWhere((p) => !p.isAI);
            final aiTop = state.players.firstWhere(
              (p) => p.name.contains('Top'),
            );
            final aiLeft = state.players.firstWhere(
              (p) => p.name.contains('Left'),
            );
            final aiRight = state.players.firstWhere(
              (p) => p.name.contains('Right'),
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                double scale = 1.0;
                double wScale = constraints.maxWidth / 430;
                double hScale = constraints.maxHeight / 880;
                scale = wScale < hScale ? wScale : hScale;
                if (scale < 0.6) scale = 0.6;

                return Stack(
                  children: [
                    Column(
                      children: [
                        // 1. Message area (Top)
                        if (state.latestMessage != null)
                          TopMessageBanner(message: state.latestMessage!),

                        // 2. Top AI Player
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ActivePlayerZone(
                              player: aiTop,
                              controller: controller,
                              isVertical: true,
                              scale: scale,
                            ),
                          ),
                        ),

                        // 3. Middle AI Players (Left & Right side by side)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ActivePlayerZone(
                                    player: aiLeft,
                                    controller: controller,
                                    isVertical: true,
                                    scale: scale,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ActivePlayerZone(
                                    player: aiRight,
                                    controller: controller,
                                    isVertical: true,
                                    scale: scale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 4. Center Play Area (Deck and Discard Pile)
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: CenterPlayArea(state: state, scale: scale),
                            ),
                          ),
                        ),

                        // 5. Bottom User and Actions
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User Zone
                              ActivePlayerZone(
                                player: user,
                                controller: controller,
                                isVertical: true,
                                scale: scale,
                              ),
                              SizedBox(height: 16 * scale),
                              // Action Buttons
                              ActionPanel(
                                controller: controller,
                                user: user,
                                scale: scale,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GameOverOverlay(controller: controller),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
