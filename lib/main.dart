import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shithead/widgets/animated_card_slot.dart';

import 'game_controller.dart';
import 'widgets/card_widget.dart';
import 'card_model.dart';

void main() {
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: ShitheadGame()));
}

class ShitheadGame extends StatelessWidget {
  ShitheadGame({super.key});

  // Safer than creating it as a field on StatelessWidget when hot reload/rebuilds happen
  final GameController controller = Get.put(GameController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      body: SafeArea(
        // Prefer smaller Obx blocks rather than rebuilding the whole screen on every Rx change.
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- AI SECTION ---
              Obx(() => _buildSectionLabel("AI Opponent (${controller.aiHand.length})")),
              Obx(() => _buildCardRow(controller.aiFaceUp)),

              const Divider(color: Colors.white10, height: 30),

              // --- TABLE / MESSAGE ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.gameMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Deck + counter
                          Column(
                            children: [
                              const CardWidget(isHidden: true),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  "${controller.deck.length} left",
                                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 20),

                          // Pile
                          controller.pile.isEmpty ? _buildEmptySlot() : CardWidget(card: controller.pile.last),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text("Pile: ${controller.pile.length}", style: const TextStyle(color: Colors.white38)),
                    ],
                  ),
                ),
              ),

              const Divider(color: Colors.white10, height: 30),

              // --- PLAYER TABLE CARDS ---
              _buildSectionLabel("Your Table Cards"),
              Obx(() => _buildCardRow(controller.playerFaceUp, isPlayerTable: true)),
              Obx(() {
                final canUseHidden =
                    !controller.isSwapPhase.value &&
                    controller.isPlayerTurn.value &&
                    controller.playerHand.isEmpty &&
                    controller.playerFaceUp.isEmpty &&
                    controller.playerHidden.isNotEmpty;

                if (!canUseHidden) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildSectionLabel("Your Hidden Cards"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(controller.playerHidden.length, (i) {
                        return CardWidget(isHidden: true, onTap: () => controller.handleHiddenClick(i));
                      }),
                    ),
                  ],
                );
              }),

              // --- PLAYER HAND ---
              _buildSectionLabel("Your Hand"),
              SizedBox(
                height: 120,
                child: Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: controller.playerHand.asMap().entries.map((entry) {
                        return AnimatedCardSlot(
                          card: entry.value,
                          isSelected: controller.selectedIndices.contains(entry.key),
                          onTap: () => controller.toggleSelection(entry.key),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Add a little breathing room ABOVE the bottom nav bar (not required, just nice)
              const Text("V 0.0.2"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildJoystickNavBar(controller),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1.2)),
    );
  }

  Widget _buildCardRow(List<CardModel> cards, {bool isPlayerTable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.asMap().entries.map((entry) {
        return AnimatedCardSlot(
          card: entry.value,
          onTap: isPlayerTable ? () => Get.find<GameController>().handleFaceUpClick(entry.key) : null,
        );
      }).toList(),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.add, color: Colors.white10)),
    );
  }

  static Widget _buildJoystickNavBar(GameController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF1E272E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              "PLAY",
              Colors.blue,
              onPressed: controller.selectedIndices.isEmpty || controller.isSwapPhase.value
                  ? null
                  : () {
                      final indices = controller.selectedIndices.toList();
                      final selected = indices.map((i) => controller.playerHand[i]).toList();
                      controller.processMove(selected, "playerHand", indices);
                    },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMidButton("NEW GAME", Colors.redAccent, controller.setupGame),
                if (controller.isSwapPhase.value)
                  _buildMidButton("READY", Colors.green, () => controller.isSwapPhase.value = false),
              ],
            ),
            _buildActionButton(
              "PICK UP",
              Colors.orange,
              onPressed: controller.pile.isEmpty || controller.hasWon.value.isNotEmpty ? null : controller.playerPickUp,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButton(String label, Color color, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        disabledBackgroundColor: Colors.white10,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  static Widget _buildMidButton(String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(80, 30)),
        child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.white)),
      ),
    );
  }
}
