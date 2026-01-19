import 'package:get/get.dart';
import 'card_model.dart';

class GameController extends GetxController {
  // --- Game State ---
  final deck = <CardModel>[].obs;
  final pile = <CardModel>[].obs;

  // Player Cards
  final playerHand = <CardModel>[].obs;
  final playerFaceUp = <CardModel>[].obs;
  final playerHidden = <CardModel>[].obs;
  final selectedIndices = <int>[].obs;

  // AI Cards
  final aiHand = <CardModel>[].obs;
  final aiFaceUp = <CardModel>[].obs;
  final aiHidden = <CardModel>[].obs;

  // Status Variables
  final isPlayerTurn = true.obs;
  final isSwapPhase = true.obs;
  final gameMessage = "Swap Phase: Prepare your table".obs;
  final hasWon = "".obs; // "Player" or "AI"

  bool _aiTurnScheduled = false;

  @override
  void onInit() {
    super.onInit();
    setupGame();
  }

  // --- Setup / Helpers ---

  void setupGame() {
    final newDeck = <CardModel>[];
    const suits = ['♠', '♣', '♥', '♦'];
    const ranks = <String, int>{
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      'J': 11,
      'Q': 12,
      'K': 13,
      'A': 14,
    };

    for (final suit in suits) {
      ranks.forEach((label, rank) {
        newDeck.add(CardModel(suit: suit, label: label, rank: rank));
      });
    }
    newDeck.shuffle();

    // Deal Player
    playerHidden.value = newDeck.sublist(0, 3);
    playerFaceUp.value = newDeck.sublist(3, 6);
    playerHand.value = sortCards(newDeck.sublist(6, 9));

    // Deal AI
    aiHidden.value = newDeck.sublist(9, 12);
    aiFaceUp.value = newDeck.sublist(12, 15);
    aiHand.value = sortCards(newDeck.sublist(15, 18));

    deck.value = newDeck.sublist(18);
    pile.clear();

    selectedIndices.clear();
    isSwapPhase.value = true;
    isPlayerTurn.value = true;
    hasWon.value = "";
    gameMessage.value = "Swap Phase: Prepare your table";

    _aiTurnScheduled = false;
  }

  List<CardModel> sortCards(List<CardModel> cards) {
    final copy = List<CardModel>.from(cards);
    copy.sort((a, b) => a.rank.compareTo(b.rank));
    return copy;
  }

  void _checkWin() {
    if (hasWon.isNotEmpty) return;

    if (playerHidden.isEmpty && playerFaceUp.isEmpty && playerHand.isEmpty) {
      hasWon.value = "Player";
      gameMessage.value = "You win!";
      return;
    }

    if (aiHidden.isEmpty && aiFaceUp.isEmpty && aiHand.isEmpty) {
      hasWon.value = "AI";
      gameMessage.value = "AI wins!";
      return;
    }
  }

  // --- Selection / Swap Phase ---

  void toggleSelection(int index) {
    // During normal play, only allow player interaction on player's turn
    if (!isSwapPhase.value && !isPlayerTurn.value) return;

    if (isSwapPhase.value) {
      // Only one card selected during swap
      selectedIndices.value = selectedIndices.contains(index) ? <int>[] : <int>[index];
      return;
    }

    // Normal play: allow selecting multiple of same rank/label
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
      return;
    }

    if (selectedIndices.isEmpty) {
      selectedIndices.add(index);
      return;
    }

    final first = playerHand[selectedIndices[0]];
    final next = playerHand[index];
    if (first.label == next.label) {
      selectedIndices.add(index);
    } else {
      selectedIndices.value = <int>[index];
    }
  }

  void handleFaceUpClick(int index) {
    if (isSwapPhase.value && selectedIndices.length == 1) {
      final handIdx = selectedIndices[0];

      // Swap Hand <-> FaceUp
      final temp = playerHand[handIdx];
      playerHand[handIdx] = playerFaceUp[index];
      playerFaceUp[index] = temp;

      // Sort ONCE and replace list
      playerHand.value = sortCards(playerHand.toList());

      // Clear selection
      selectedIndices.clear();
      return;
    }

    // Normal play: if hand empty, can play face-up
    if (!isSwapPhase.value && isPlayerTurn.value && playerHand.isEmpty) {
      processMove([playerFaceUp[index]], "playerFaceUp", index);
    }
  }

  // --- Rules ---

  bool isValidMove(CardModel card) {
    if (pile.isEmpty) return true;

    final topCard = pile.last;

    // Always valid specials
    if (card.isReset || card.isBurn) return true;

    // Your custom rule (keep if intended)
    if (topCard.rank == 5) return card.rank <= 5;

    return card.rank >= topCard.rank;
  }

  // --- Core Move Processing ---

  void processMove(List<CardModel> cards, String source, dynamic indexInfo) {
    if (cards.isEmpty) return;
    if (hasWon.isNotEmpty) return;

    final actorIsAi = source.startsWith("ai");
    final canPlay = isValidMove(cards[0]);

    if (!canPlay) {
      // Invalid move: remove attempted cards from source, then pick up pile + attempted cards
      _removeCardsFromSource(source, cards, indexInfo);

      final pickUp = <CardModel>[...pile, ...cards];
      pile.clear();

      if (actorIsAi) {
        aiHand.value = sortCards([...aiHand, ...pickUp]);
      } else {
        playerHand.value = sortCards([...playerHand, ...pickUp]);
      }

      gameMessage.value = "Invalid move! ${actorIsAi ? "AI" : "You"} picked up the pile.";
      selectedIndices.clear();

      // Turn passes to opponent
      isPlayerTurn.value = actorIsAi;
      if (!isPlayerTurn.value) _scheduleAiTurn();

      _checkWin();
      return;
    }

    // Valid play: add cards to pile
    pile.addAll(cards);

    // Burn: 10 or 4-of-a-kind on top
    final isBurn =
        cards[0].isBurn || (pile.length >= 4 && pile.sublist(pile.length - 4).every((c) => c.label == pile.last.label));

    // Remove from source + draw up to 3 (hand sources)
    _removeCardsFromSource(source, cards, indexInfo);

    if (isBurn) {
      pile.clear();
      gameMessage.value = actorIsAi ? "AI BURNED IT! AI goes again." : "BURNED! Go again.";

      // Same player keeps turn
      isPlayerTurn.value = !actorIsAi;

      selectedIndices.clear();
      _checkWin();

      if (actorIsAi) _scheduleAiTurn();
      return;
    }

    gameMessage.value = "${actorIsAi ? "AI" : "You"} played ${cards[0].label}";

    // Normal turn flip
    isPlayerTurn.value = actorIsAi; // if AI played -> player turn true; if player played -> false
    selectedIndices.clear();

    _checkWin();
    if (!isPlayerTurn.value && hasWon.isEmpty) _scheduleAiTurn();
  }

  void _removeCardsFromSource(String source, List<CardModel> cards, dynamic indexInfo) {
    switch (source) {
      case "playerHand":
        // Remove by indices (safer than removeWhere)
        final indices = (indexInfo as List<int>?) ?? <int>[];
        final sorted = [...indices]..sort((a, b) => b.compareTo(a));
        for (final i in sorted) {
          if (i >= 0 && i < playerHand.length) {
            playerHand.removeAt(i);
          }
        }

        // Draw up to 3 from deck
        while (playerHand.length < 3 && deck.isNotEmpty) {
          playerHand.add(deck.removeAt(0));
        }
        playerHand.value = sortCards(playerHand.toList());
        break;

      case "playerFaceUp":
        if (indexInfo is int && indexInfo >= 0 && indexInfo < playerFaceUp.length) {
          playerFaceUp.removeAt(indexInfo);
        }
        break;

      case "playerHidden":
        if (indexInfo is int && indexInfo >= 0 && indexInfo < playerHidden.length) {
          playerHidden.removeAt(indexInfo);
        }
        break;

      case "aiHand":
        // Remove the exact cards played
        for (final c in cards) {
          aiHand.remove(c);
        }

        // Draw up to 3 from deck
        while (aiHand.length < 3 && deck.isNotEmpty) {
          aiHand.add(deck.removeAt(0));
        }
        aiHand.value = sortCards(aiHand.toList());
        break;

      case "aiFaceUp":
        if (indexInfo is int && indexInfo >= 0 && indexInfo < aiFaceUp.length) {
          aiFaceUp.removeAt(indexInfo);
        }
        break;

      case "aiHidden":
        if (indexInfo is int && indexInfo >= 0 && indexInfo < aiHidden.length) {
          aiHidden.removeAt(indexInfo);
        }
        break;
    }

    _checkWin();
  }

  // --- AI Turn Scheduling / AI Logic ---

  void _scheduleAiTurn() {
    if (_aiTurnScheduled) return;
    _aiTurnScheduled = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      _aiTurnScheduled = false;
      executeAiTurn();
    });
  }

  void executeAiTurn() {
    if (hasWon.isNotEmpty) return;
    if (isPlayerTurn.value) return;
    if (isSwapPhase.value) return; // AI doesn't act during swap phase

    // 1) Try Hand
    final playable = aiHand.where(isValidMove).toList();
    if (playable.isNotEmpty) {
      playable.sort((a, b) => a.rank.compareTo(b.rank));
      final best = playable.first;

      // Play all of same label (multi-card)
      final cardsToPlay = aiHand.where((c) => c.label == best.label).toList();
      processMove(cardsToPlay, "aiHand", null);
      return;
    }

    // 2) Try FaceUp (only when hand empty)
    if (aiHand.isEmpty && aiFaceUp.isNotEmpty) {
      final playableFaceUp = aiFaceUp.where(isValidMove).toList();
      if (playableFaceUp.isNotEmpty) {
        final chosen = playableFaceUp.first;
        final idx = aiFaceUp.indexOf(chosen);
        processMove([aiFaceUp[idx]], "aiFaceUp", idx);
        return;
      }
    }

    // 3) Try Hidden (only when hand and face-up empty)
    if (aiHand.isEmpty && aiFaceUp.isEmpty && aiHidden.isNotEmpty) {
      // In classic Shithead, this is blind. Keep as first card.
      processMove([aiHidden[0]], "aiHidden", 0);
      return;
    }

    // 4) Must pick up pile (ONLY AI picks up)
    if (pile.isNotEmpty) {
      aiHand.value = sortCards([...aiHand, ...pile]);
      pile.clear();
      gameMessage.value = "AI picked up the pile!";
    }

    isPlayerTurn.value = true;
  }

  // --- Player Actions ---

  void playerPickUp() {
    if (pile.isEmpty) return;
    if (hasWon.isNotEmpty) return;

    playerHand.value = sortCards([...playerHand, ...pile]);
    pile.clear();

    gameMessage.value = "You picked up the pile.";
    selectedIndices.clear();

    isPlayerTurn.value = false;
    _scheduleAiTurn();

    _checkWin();
  }

  void handleHiddenClick(int index) {
    if (isSwapPhase.value) return;
    if (!isPlayerTurn.value) return;

    // Only allow hidden plays when hand and face-up are empty
    if (playerHand.isNotEmpty) return;
    if (playerFaceUp.isNotEmpty) return;

    if (index < 0 || index >= playerHidden.length) return;

    processMove([playerHidden[index]], "playerHidden", index);
  }
}
