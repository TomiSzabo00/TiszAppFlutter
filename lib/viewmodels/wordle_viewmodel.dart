import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/wordle/word.dart';
import 'package:tiszapp_flutter/models/wordle/wordle_game_status.dart';
import '../models/wordle/letter.dart';
import '../models/wordle/letter_status.dart';

class WordleViewModel with ChangeNotifier {
  WordleGameStatus gameStatus = WordleGameStatus.inProgress;

  final List<Word> board = List.generate(
      6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));

  int currentWordIndex = 0;

  Word? get currentWord =>
      currentWordIndex < board.length ? board[currentWordIndex] : null;

  Word solution = Word.fromStr("TISZA");
  Word solutionCopy = Word.fromStr("");

  final Set<Letter> keyboardLetters = {};

  final List<List<GlobalKey<FlipCardState>>> flipCardKeys = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => GlobalKey<FlipCardState>(),
    ),
  );

  WordleViewModel();

  void init() {
    // TODO: get solution from firebase
    solutionCopy = Word.fromStr(solution.wordString);
  }

  void onLetterTap(String letter) {
    if (gameStatus == WordleGameStatus.inProgress) {
      currentWord?.addLetter(letter);
      notifyListeners();
    }
  }

  void onBackspaceTap() {
    if (gameStatus == WordleGameStatus.inProgress) {
      currentWord?.removeLetter();
      notifyListeners();
    }
  }

  void onEnterTap() async {
    if (gameStatus == WordleGameStatus.inProgress &&
        currentWord != null &&
        !currentWord!.letters.contains(Letter.empty())) {
      gameStatus = WordleGameStatus.submitting;
      solutionCopy = Word.fromStr(solution.wordString);

      for (var i = 0; i < currentWord!.letters.length; i++) {
        final currLetter = currentWord!.letters[i];

        if (currLetter.letter == solution.letters[i].letter) {
          final copyIndex = solutionCopy.letters
              .indexWhere((element) => element.letter == currLetter.letter);
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          currentWord!.letters[i] =
              currLetter.copyWith(status: LetterStatus.correct);
        }
      }

      for (var i = 0; i < currentWord!.letters.length; i++) {
        final currLetter = currentWord!.letters[i];
        if (currLetter.status == LetterStatus.correct) {
          continue;
        }

        if (solutionCopy.letters.contains(currLetter)) {
          final copyIndex = solutionCopy.letters
              .indexWhere((element) => element.letter == currLetter.letter);
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          currentWord!.letters[i] =
              currLetter.copyWith(status: LetterStatus.inWord);
        } else {
          currentWord!.letters[i] =
              currLetter.copyWith(status: LetterStatus.notInWord);
        }
      }

      // flip the cards and reveal their state
      for (var i = 0; i < currentWord!.letters.length; i++) {
        final currLetter = currentWord!.letters[i];
        await Future.delayed(
          const Duration(milliseconds: 150),
          () {
            // flip cards
            flipCardKeys[currentWordIndex][i].currentState?.toggleCard();
            
            // add state to keyboard
            final letter = keyboardLetters.firstWhere(
              (element) => element.letter == currLetter.letter,
              orElse: () => Letter.empty(),
            );
            if (letter.status != LetterStatus.correct) {
              keyboardLetters.removeWhere(
                  (element) => element.letter == currLetter.letter);
              keyboardLetters.add(currentWord!.letters[i]);
            }
            
            notifyListeners();
          },
        );
      }

      checkForGameEnd();
    }
  }

  void checkForGameEnd() {
    if (currentWord!.wordString == solution.wordString) {
      gameStatus = WordleGameStatus.won;
    } else if (currentWordIndex == board.length - 1) {
      gameStatus = WordleGameStatus.lost;
    } else {
      currentWordIndex++;
      gameStatus = WordleGameStatus.inProgress;
    }
    notifyListeners();
  }
}
