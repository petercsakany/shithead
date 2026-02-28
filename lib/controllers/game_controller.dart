import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class GameController extends ChangeNotifier {
  late GameState state;
  bool isGameOver = false;

  GameController() {
    startNewGame();
  }

  void startNewGame() {
    isGameOver = false;
    final deck = Deck();
    final players = [
      Player(id: 'user', name: 'You', isAI: false),
      Player(id: 'ai1', name: 'AI Left'),
      Player(id: 'ai2', name: 'AI Top'),
      Player(id: 'ai3', name: 'AI Right'),
    ];

    state = GameState(deck: deck, players: players, discardPile: [], selectedCards: []);

    _dealCards();
    state.currentPhase = GamePhase.playing;
    _checkAITurn();
    notifyListeners();
  }

  void _dealCards() {
    for (int i = 0; i < 3; i++) {
      for (var p in state.players) {
        p.faceDownCards.add(state.deck.drawCard());
      }
    }
    for (int i = 0; i < 3; i++) {
      for (var p in state.players) {
        p.faceUpCards.add(state.deck.drawCard());
      }
    }
    for (int i = 0; i < 3; i++) {
      for (var p in state.players) {
        p.hand.add(state.deck.drawCard());
      }
    }
    _replenishHands();
  }

  void _replenishHands() {
    for (var p in state.players) {
      while (p.hand.length < 3 && !state.deck.isEmpty) {
        p.hand.add(state.deck.drawCard());
      }
      p.sortHand();
    }
  }

  bool canPlayCard(PlayingCard card) {
    if (state.discardPile.isEmpty) return true;

    // 2s and 10s can be played on anything
    if (card.clearsPile || card.burnsPile) return true;

    final topCard = state.topCard!;

    // If top card is a 2, you can play anything
    if (topCard.clearsPile) return true;

    // If top card is a 7, must play lower than a 7 (or equal)
    if (topCard.forcesLower) {
      return card.rank.value <= 7;
    }

    return card.rank.value >= topCard.rank.value;
  }

  void toggleCardSelection(Player p, PlayingCard card) {
    if (p.id != state.currentPlayer.id) return;

    if (state.selectedCards.contains(card)) {
      state.selectedCards.remove(card);
      notifyListeners();
      return;
    }

    if (state.selectedCards.isEmpty) {
      state.selectedCards.add(card);
    } else {
      if (state.selectedCards.first.rank == card.rank) {
        state.selectedCards.add(card);
      } else {
        state.selectedCards.clear();
        state.selectedCards.add(card);
      }
    }
    notifyListeners();
  }

  Future<void> playSelectedCards(Player p) async {
    if (p.id != state.currentPlayer.id) return;
    if (state.selectedCards.isEmpty) return;

    // All selected cards are of the same rank, check if the first can be played
    if (!canPlayCard(state.selectedCards.first)) return;

    final cardsToPlay = List<PlayingCard>.from(state.selectedCards);
    state.selectedCards.clear();

    for (var card in cardsToPlay) {
      if (p.hand.contains(card)) {
        p.hand.remove(card);
      } else if (p.faceUpCards.contains(card)) {
        p.faceUpCards.remove(card);
      } else if (p.faceDownCards.contains(card)) {
        p.faceDownCards.remove(card);
      }
      state.discardPile.add(card);
    }

    state.messageHistory.add(
      '${p.name} played ${cardsToPlay.length > 1 ? '${cardsToPlay.length} ' : ''}${cardsToPlay.first.rank.name}${cardsToPlay.length > 1 ? 's' : ''}',
    );
    _replenishHands();

    bool hasBurned = false;

    // check special cards (e.g. 10 burns pile)
    if (cardsToPlay.first.burnsPile) {
      hasBurned = true;
    } else if (state.discardPile.length >= 4) {
      // check for 4-of-a-kind burn
      final top4 = state.discardPile.sublist(state.discardPile.length - 4);
      if (top4.every((c) => c.rank == top4.first.rank)) {
        hasBurned = true;
      }
    }

    if (hasBurned) {
      state.discardPile.clear();
      state.messageHistory.add('${p.name} burnt the pile!');
      _checkWinCondition();
      notifyListeners();
      _checkAITurn();
      return;
    }

    if (cardsToPlay.first.clearsPile) {
      state.messageHistory.add('${p.name} reset the pile with a 2.');
    }

    _nextTurn();
  }

  void pickUpPile(Player p) {
    if (p.id != state.currentPlayer.id) return;
    if (state.discardPile.isEmpty) return;

    p.hand.addAll(state.discardPile);
    state.discardPile.clear();
    p.sortHand();

    state.messageHistory.add('${p.name} picked up the pile.');
    _nextTurn();
  }

  void _nextTurn() {
    _checkWinCondition();
    if (isGameOver) return;

    state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
    notifyListeners();
    _checkAITurn();
  }

  void _checkWinCondition() {
    for (var p in state.players) {
      if (p.hasWon) {
        isGameOver = true;
        state.messageHistory.add('${p.name} WON THE GAME!');
        notifyListeners();
        return;
      }
    }
  }

  Future<void> _checkAITurn() async {
    if (isGameOver) return;

    final p = state.currentPlayer;
    if (!p.isAI) return;

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate thinking

    // Find playable cards
    List<PlayingCard> validPlay = [];

    if (p.canPlayFromHand()) {
      validPlay = p.hand.where((c) => canPlayCard(c)).toList();
    } else if (p.canPlayFromFaceUp()) {
      validPlay = p.faceUpCards.where((c) => canPlayCard(c)).toList();
    } else if (p.canPlayFromFaceDown()) {
      // AI must guess a face-down card... just pick the first one
      final guessCard = p.faceDownCards.first;
      if (canPlayCard(guessCard)) {
        state.selectedCards.clear();
        state.selectedCards.add(guessCard);
        await playSelectedCards(p);
        return;
      } else {
        // Failed guess
        p.faceDownCards.remove(guessCard);
        state.discardPile.add(guessCard);
        pickUpPile(p);
        return;
      }
    }

    if (validPlay.isEmpty) {
      pickUpPile(p);
    } else {
      Map<Rank, List<PlayingCard>> playableGroups = {};
      for (var card in validPlay) {
        playableGroups.putIfAbsent(card.rank, () => []).add(card);
      }

      // sort groups to find best play
      List<List<PlayingCard>> groups = playableGroups.values.toList();
      groups.sort((a, b) {
        if (a.first.clearsPile && !b.first.clearsPile) return 1;
        if (!a.first.clearsPile && b.first.clearsPile) return -1;
        if (a.first.burnsPile && !b.first.burnsPile) return 1;
        if (!a.first.burnsPile && b.first.burnsPile) return -1;
        // play largest group first if it's not a special card
        if (a.length != b.length) return b.length.compareTo(a.length);
        return a.first.rank.value.compareTo(b.first.rank.value);
      });

      // Select cards to play
      state.selectedCards.clear();
      state.selectedCards.addAll(groups.first);

      await playSelectedCards(p);
    }
  }
}
