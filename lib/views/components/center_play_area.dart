import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import 'card_widget.dart';

class CenterPlayArea extends StatelessWidget {
  final GameState state;
  final double scale;

  const CenterPlayArea({super.key, required this.state, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
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
                    child: CardWidget(
                      card: null,
                      isFaceUp: false,
                      width: 75 * scale,
                      height: 110 * scale,
                    ),
                  ),
                if (state.deck.remaining > 1)
                  Positioned(
                    left: 1 * scale,
                    top: 1 * scale,
                    child: CardWidget(
                      card: null,
                      isFaceUp: false,
                      width: 75 * scale,
                      height: 110 * scale,
                    ),
                  ),
                if (state.deck.remaining > 0)
                  CardWidget(
                    card: null,
                    isFaceUp: false,
                    width: 75 * scale,
                    height: 110 * scale,
                  )
                else
                  Container(
                    width: 75 * scale,
                    height: 110 * scale,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid,
                      ),
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
              CardWidget(
                card: state.topCard,
                isFaceUp: true,
                width: 75 * scale,
                height: 110 * scale,
              )
            else
              Container(
                width: 75 * scale,
                height: 110 * scale,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                    style: BorderStyle.solid,
                  ),
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
}
