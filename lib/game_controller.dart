import 'package:get/get.dart';
import 'dart:async';
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

    playerHidden.value = newDeck.sublist(0, 3);
    playerFaceUp.value = newDeck.sublist(3, 6);
    playerHand.value = _sortList(newDeck.sublist(6, 9));

    aiHidden.value = newDeck.sublist(9, 12);
    aiFaceUp.value = newDeck.sublist(12, 15);
    aiHand.value = _sortList(newDeck.sublist(15, 18));

    deck.value = newDeck.sublist(18);
    pile.clear();
    selectedIndices.clear();

    isSwapPhase.value = true;
    isPlayerTurn.value = true;
    hasWon.value = "";
    gameMessage.value = "Swap Phase: Prepare your table";
    _aiTurnScheduled = false;
  }

  List<CardModel> _sortList(List<CardModel> cards) {
    return cards..sort((a, b) => a.rank.compareTo(b.rank));
  }

  void _checkWin() {
    if (hasWon.isNotEmpty) return;
    if (playerHidden.isEmpty && playerFaceUp.isEmpty && playerHand.isEmpty) {
      hasWon.value = "Player";
      gameMessage.value = "You win!";
    } else if (aiHidden.isEmpty && aiFaceUp.isEmpty && aiHand.isEmpty) {
      hasWon.value = "AI";
      gameMessage.value = "AI wins!";
    }
  }

  // --- Selection / Swap Phase ---

  void toggleSelection(int index) {
    if (!isSwapPhase.value && !isPlayerTurn.value) return;

    if (isSwapPhase.value) {
      selectedIndices.value = selectedIndices.contains(index) ? [] : [index];
      return;
    }

    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else if (selectedIndices.isEmpty || playerHand[selectedIndices[0]].label == playerHand[index].label) {
      selectedIndices.add(index);
    } else {
      selectedIndices.value = [index];
    }
  }

  void handleFaceUpClick(int index) {
    if (isSwapPhase.value && selectedIndices.length == 1) {
      final handIdx = selectedIndices[0];

      final temp = playerHand[handIdx];
      playerHand[handIdx] = playerFaceUp[index];
      playerFaceUp[index] = temp;

      playerHand.sort((a, b) => a.rank.compareTo(b.rank));
      playerHand.refresh();
      playerFaceUp.refresh();
      selectedIndices.clear();
      return;
    }

    if (!isSwapPhase.value && isPlayerTurn.value && playerHand.isEmpty) {
      processMove([playerFaceUp[index]], "playerFaceUp", index);
    }
  }

  // --- Rules ---

  bool isValidMove(CardModel card) {
    if (pile.isEmpty) return true;
    final topCard = pile.last;
    if (card.isReset || card.isBurn) return true;
    if (topCard.rank == 5) return card.rank <= 5;
    return card.rank >= topCard.rank;
  }

  // --- Core Move Processing ---

  void processMove(List<CardModel> cards, String source, dynamic indexInfo) {
    if (cards.isEmpty || hasWon.isNotEmpty) return;

    final actorIsAi = source.startsWith("ai");
    final canPlay = isValidMove(cards[0]);

    if (!canPlay) {
      // REFINED: Blind Play Fail (Hidden cards)
      if (source == "playerHidden") {
        final failedCard = cards[0];
        final pickUp = <CardModel>[...pile, failedCard];
        pile.clear();
        playerHidden.removeAt(indexInfo);

        playerHand.addAll(pickUp);
        playerHand.sort((a, b) => a.rank.compareTo(b.rank));
        playerHand.refresh();

        gameMessage.value = "Blind Play Failed! You picked up the pile.";
        isPlayerTurn.value = false;
        _scheduleAiTurn();
        return;
      }

      if (!actorIsAi) {
        gameMessage.value = "Invalid move. Choose a valid card or pick up.";
        return;
      }

      // AI Failure Logic
      _removeCardsFromSource(source, cards, indexInfo);
      aiHand.addAll([...pile, ...cards]);
      aiHand.sort((a, b) => a.rank.compareTo(b.rank));
      aiHand.refresh();
      pile.clear();
      gameMessage.value = "AI couldn't play and picked up the pile.";
      isPlayerTurn.value = true;
      return;
    }

    // Valid play logic
    pile.addAll(cards);
    final isBurn =
        cards[0].isBurn || (pile.length >= 4 && pile.sublist(pile.length - 4).every((c) => c.label == pile.last.label));

    _removeCardsFromSource(source, cards, indexInfo);

    if (isBurn) {
      pile.clear();
      gameMessage.value = actorIsAi ? "AI BURNED IT! AI goes again." : "BURNED! Go again.";
      isPlayerTurn.value = !actorIsAi;
      if (actorIsAi) _scheduleAiTurn();
    } else {
      gameMessage.value = "${actorIsAi ? "AI" : "You"} played ${cards[0].label}";
      isPlayerTurn.value = actorIsAi; // Flip turn
      if (!isPlayerTurn.value) _scheduleAiTurn();
    }

    selectedIndices.clear();
    _checkWin();
  }

  void _removeCardsFromSource(String source, List<CardModel> cards, dynamic indexInfo) {
    switch (source) {
      case "playerHand":
        final indices = List<int>.from(indexInfo)..sort((a, b) => b.compareTo(a));
        for (var i in indices) {
          playerHand.removeAt(i);
        }
        while (playerHand.length < 3 && deck.isNotEmpty) {
          playerHand.add(deck.removeAt(0));
        }
        playerHand.sort((a, b) => a.rank.compareTo(b.rank));
        playerHand.refresh();
        break;
      case "playerFaceUp":
        playerFaceUp.removeAt(indexInfo);
        break;
      case "playerHidden":
        playerHidden.removeAt(indexInfo);
        break;
      case "aiHand":
        for (var c in cards) {
          aiHand.remove(c);
        }
        while (aiHand.length < 3 && deck.isNotEmpty) {
          aiHand.add(deck.removeAt(0));
        }
        aiHand.sort((a, b) => a.rank.compareTo(b.rank));
        aiHand.refresh();
        break;
      case "aiFaceUp":
        aiFaceUp.removeAt(indexInfo);
        break;
      case "aiHidden":
        aiHidden.removeAt(indexInfo);
        break;
    }
  }

  // --- AI Turn Logic ---

  void _scheduleAiTurn() {
    if (_aiTurnScheduled || hasWon.isNotEmpty) return;
    _aiTurnScheduled = true;
    Future.delayed(const Duration(milliseconds: 1200), () {
      _aiTurnScheduled = false;
      executeAiTurn();
    });
  }

  void executeAiTurn() {
    if (hasWon.isNotEmpty || isPlayerTurn.value || isSwapPhase.value) return;

    // 1) Hand
    final playable = aiHand.where(isValidMove).toList();
    if (playable.isNotEmpty) {
      playable.sort((a, b) => a.rank.compareTo(b.rank));
      final cardsToPlay = aiHand.where((c) => c.label == playable.first.label).toList();
      processMove(cardsToPlay, "aiHand", null);
      return;
    }

    // 2) FaceUp
    if (aiHand.isEmpty && aiFaceUp.isNotEmpty) {
      final playableFaceUp = aiFaceUp.where(isValidMove).toList();
      if (playableFaceUp.isNotEmpty) {
        final idx = aiFaceUp.indexOf(playableFaceUp.first);
        processMove([aiFaceUp[idx]], "aiFaceUp", idx);
        return;
      }
    }

    // 3) Hidden
    if (aiHand.isEmpty && aiFaceUp.isEmpty && aiHidden.isNotEmpty) {
      processMove([aiHidden[0]], "aiHidden", 0);
      return;
    }

    // 4) Pickup
    if (pile.isNotEmpty) {
      aiHand.addAll(pile);
      aiHand.sort((a, b) => a.rank.compareTo(b.rank));
      aiHand.refresh();
      pile.clear();
      gameMessage.value = "AI picked up the pile!";
    }
    isPlayerTurn.value = true;
  }

  // --- Player Actions ---

  void playerPickUp() {
    // GUARD: Prevent pickup if not player's turn or game over
    if (!isPlayerTurn.value || pile.isEmpty || hasWon.isNotEmpty || isSwapPhase.value) return;

    playerHand.addAll(pile);
    playerHand.sort((a, b) => a.rank.compareTo(b.rank));
    playerHand.refresh();
    pile.clear();

    gameMessage.value = "You picked up the pile.";
    selectedIndices.clear();
    isPlayerTurn.value = false;
    _scheduleAiTurn();
  }

  void handleHiddenClick(int index) {
    // Guard: Only allow hidden plays if it's your turn and not swapping
    if (isSwapPhase.value || !isPlayerTurn.value || hasWon.isNotEmpty) return;

    // Guard: Standard rules say you can't play hidden cards until hand and face-up are gone
    if (playerHand.isNotEmpty || playerFaceUp.isNotEmpty) {
      gameMessage.value = "Finish your hand and face-up cards first!";
      return;
    }

    if (index < 0 || index >= playerHidden.length) return;

    // Trigger the move processing we refined earlier
    processMove([playerHidden[index]], "playerHidden", index);
  }
}
