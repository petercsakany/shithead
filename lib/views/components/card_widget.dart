import 'package:flutter/material.dart';
import '../../models/card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isFaceUp;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isPlayable;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.isFaceUp = true,
    this.onTap,
    this.isSelected = false,
    this.isPlayable = true,
    this.width = 60,
    this.height = 90,
  });

  Color _getSuitColor(Suit suit) {
    if (suit == Suit.hearts || suit == Suit.diamonds) {
      return Colors.red;
    }
    return Colors.black;
  }

  String _getSuitSymbol(Suit suit) {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (card == null && isFaceUp) {
      // Empty slot
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.white24, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: isFaceUp ? Colors.white : Colors.blue.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.green : Colors.black26, width: isSelected || !isFaceUp ? 2 : 1),
          boxShadow: [
            if (isSelected || !isFaceUp)
              const BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1, offset: Offset(0, 2)),
          ],
        ),
        child: isFaceUp
            ? Stack(
                children: [
                  // Top left text
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Text(
                      card!.toString().split(' ').first,
                      style: TextStyle(color: _getSuitColor(card!.suit), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Center Icon
                  Center(
                    child: Text(
                      _getSuitSymbol(card!.suit),
                      style: TextStyle(color: _getSuitColor(card!.suit), fontSize: 24),
                    ),
                  ),
                  // Bottom right text
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Transform.rotate(
                      angle: 3.14159,
                      child: Text(
                        card!.toString().split(' ').first,
                        style: TextStyle(color: _getSuitColor(card!.suit), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (!isPlayable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              )
            : Center(
                child: Container(
                  width: width * 0.7,
                  height: height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade300, width: 1),
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade300, width: 1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
