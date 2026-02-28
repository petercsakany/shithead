enum Suit { hearts, diamonds, clubs, spades }

enum Rank {
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(11),
  queen(12),
  king(13),
  ace(14);

  final int value;
  const Rank(this.value);

  @override
  String toString() {
    switch (this) {
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ace:
        return 'A';
      default:
        return value.toString();
    }
  }
}

class PlayingCard {
  final Suit suit;
  final Rank rank;

  PlayingCard({required this.suit, required this.rank});

  bool get clearsPile => rank == Rank.two;
  bool get burnsPile => rank == Rank.ten;
  bool get forcesLower => rank == Rank.seven;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '${rank.toString()} of ${suit.name}';
}
