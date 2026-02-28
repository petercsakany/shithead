import 'card.dart';

class Deck {
  final List<PlayingCard> _cards = [];

  Deck() {
    _initializeMainDeck();
    shuffle();
  }

  void _initializeMainDeck() {
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void shuffle() {
    _cards.shuffle();
  }

  bool get isEmpty => _cards.isEmpty;

  int get remaining => _cards.length;

  PlayingCard drawCard() {
    if (isEmpty) {
      throw StateError('Cannot draw from empty deck');
    }
    return _cards.removeLast();
  }

  List<PlayingCard> drawCards(int count) {
    if (count > _cards.length) {
      count = _cards.length;
    }
    final drawn = <PlayingCard>[];
    for (int i = 0; i < count; i++) {
      drawn.add(_cards.removeLast());
    }
    return drawn;
  }
}
