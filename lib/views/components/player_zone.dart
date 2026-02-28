import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/card.dart';
import 'card_widget.dart';

class PlayerZone extends StatelessWidget {
  final Player player;
  final bool isUser;
  final void Function(PlayingCard card)? onPlayCard;
  final bool Function(PlayingCard card)? isCardSelected;
  final double scale;

  const PlayerZone({
    super.key,
    required this.player,
    this.isUser = false,
    this.onPlayCard,
    this.isCardSelected,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isUser)
          Text(
            "${player.name} (${player.hand.length})",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        SizedBox(height: 8 * scale),
        // 3-Tier Table Cards
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            PlayingCard? faceUpCard = index < player.faceUpCards.length ? player.faceUpCards[index] : null;
            PlayingCard? faceDownCard = index < player.faceDownCards.length ? player.faceDownCards[index] : null;

            bool canPlayFaceUp = isUser && player.canPlayFromFaceUp() && faceUpCard != null;
            bool canPlayFaceDown = isUser && player.canPlayFromFaceDown() && faceDownCard != null && faceUpCard == null;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0 * scale),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Face down undercard
                  if (faceDownCard != null)
                    GestureDetector(
                      onTap: canPlayFaceDown ? () => onPlayCard?.call(faceDownCard) : null,
                      child: CardWidget(
                        card: faceDownCard,
                        isFaceUp: false,
                        width: 55 * scale,
                        height: 85 * scale,
                        isPlayable: canPlayFaceDown,
                        isSelected: isCardSelected?.call(faceDownCard) ?? false,
                      ),
                    )
                  else
                    SizedBox(width: 55 * scale, height: 85 * scale),

                  // Face up card on top
                  if (faceUpCard != null)
                    GestureDetector(
                      onTap: canPlayFaceUp ? () => onPlayCard?.call(faceUpCard) : null,
                      child: CardWidget(
                        card: faceUpCard,
                        isFaceUp: true,
                        width: 55 * scale,
                        height: 85 * scale,
                        isPlayable: canPlayFaceUp,
                        isSelected: isCardSelected?.call(faceUpCard) ?? false,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 12 * scale),
        // Hand Cards
        if (isUser)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: player.hand.map((c) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0 * scale),
                  child: GestureDetector(
                    onTap: () => onPlayCard?.call(c),
                    child: CardWidget(
                      card: c,
                      isFaceUp: true,
                      isPlayable: true,
                      isSelected: isCardSelected?.call(c) ?? false,
                      width: 75 * scale,
                      height: 110 * scale,
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          SizedBox(height: 45 * scale), // Maintain some spacing where hand would be
      ],
    );
  }
}
