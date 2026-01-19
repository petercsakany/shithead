class CardModel {
  /// Suit symbol: ♠ ♣ ♥ ♦
  final String suit;

  /// Face label shown on card: 2–10, J, Q, K, A
  final String label;

  /// Numeric strength used for comparisons (2–14)
  final int rank;

  const CardModel({required this.suit, required this.label, required this.rank});

  /// Red cards (hearts / diamonds)
  bool get isRed => suit == '♥' || suit == '♦';

  /// Shithead rule helpers
  bool get isReset => rank == 2;
  bool get isBurn => rank == 10;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardModel && other.suit == suit && other.label == label && other.rank == rank;
  }

  @override
  int get hashCode => Object.hash(suit, label, rank);

  @override
  String toString() => '$label$suit';
}
