import 'package:flutter/material.dart';
import '../card_model.dart';
import 'card_widget.dart';

class AnimatedCardSlot extends StatelessWidget {
  final CardModel? card;
  final bool isHidden;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnimatedCardSlot({super.key, this.card, this.isHidden = false, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Key is what tells AnimatedSwitcher “this is a different card now”
    final key = ValueKey(isHidden ? 'hidden' : (card?.toString() ?? 'null'));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        // simple + clean: fade + slight scale
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: CardWidget(key: key, card: card, isHidden: isHidden, isSelected: isSelected, onTap: onTap),
    );
  }
}
