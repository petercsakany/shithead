import 'card.dart';
import 'deck.dart';
import 'player.dart';

enum GamePhase { setup, swap, playing }

class GameState {
  final Deck deck;
  final List<Player> players;
  final List<PlayingCard> discardPile;
  final List<PlayingCard> selectedCards;

  int currentPlayerIndex = 0;
  GamePhase currentPhase = GamePhase.setup;

  final List<String> messageHistory = [];

  GameState({required this.deck, required this.players, this.discardPile = const [], this.selectedCards = const []});

  Player get currentPlayer => players[currentPlayerIndex];

  String? get latestMessage {
    if (messageHistory.isEmpty) return null;
    return messageHistory.last;
  }

  PlayingCard? get topCard {
    if (discardPile.isEmpty) return null;
    return discardPile.last;
  }
}
