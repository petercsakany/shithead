import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel? card;
  final bool isHidden;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardWidget({super.key, this.card, this.isHidden = false, this.isSelected = false, this.onTap});

  static const double _w = 70;
  static const double _h = 100;

  @override
  Widget build(BuildContext context) {
    final showBack = isHidden || card == null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
        width: _w,
        height: _h,
        decoration: BoxDecoration(
          color: showBack ? const Color(0xFFB33939) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.cyan, width: 3) : null,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: showBack ? _buildBack() : _buildFront(card!),
      ),
    );
  }

  Widget _buildFront(CardModel card) {
    final color = card.isRed ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              card.label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),

          Text(card.suit, style: TextStyle(fontSize: 26, height: 1, color: color)),

          Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: math.pi,
              child: Text(
                card.label,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xFFB33939), Color(0xFF8B2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
