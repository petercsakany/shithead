import 'card.dart';

class Player {
  final String id;
  final String name;
  final bool isAI;

  List<PlayingCard> hand = [];
  List<PlayingCard> faceUpCards = [];
  List<PlayingCard> faceDownCards = [];

  Player({required this.id, required this.name, this.isAI = true});

  bool get hasWon => hand.isEmpty && faceUpCards.isEmpty && faceDownCards.isEmpty;

  void sortHand() {
    hand.sort((a, b) => a.rank.value.compareTo(b.rank.value));
  }

  bool canPlayFromHand() => hand.isNotEmpty;
  bool canPlayFromFaceUp() => hand.isEmpty && faceUpCards.isNotEmpty;
  bool canPlayFromFaceDown() => hand.isEmpty && faceUpCards.isEmpty && faceDownCards.isNotEmpty;
}
