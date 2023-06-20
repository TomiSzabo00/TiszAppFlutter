import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/wordle/letter.dart';
import 'package:tiszapp_flutter/models/wordle/letter_status.dart';
import 'package:tiszapp_flutter/models/wordle/word.dart';
import 'package:tiszapp_flutter/models/wordle/wordle_game_status.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordleViewModel with ChangeNotifier {
  WordleGameStatus gameStatus = WordleGameStatus.inProgress;

  List<Word> board = List.generate(
      6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));

  int currentWordIndex = 0;

  Word get currentWord =>
      currentWordIndex < board.length ? board[currentWordIndex] : board.last;

  Word solution = Word.fromStr("TISZA");
  Word solutionCopy = Word.fromStr("");

  List<String> possibleWords = [];
  bool isLoading = true;
  bool shouldShowNoWordError = false;

  final Set<Letter> keyboardLetters = {};

  final List<List<FlipCardController>> flipCardControllers = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => FlipCardController(),
    ),
  );

  final List<List<bool>> shouldCardBeFlipped = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => false,
    ),
  );

  WordleViewModel() {
    init();
  }

  void init() async {
    isLoading = true;
    solution = Word.fromStr(await _getSolution());
    board = await _getStateFromFirebase();
    _updateBoardTileStates();
    _updateKeyboardTiles();
    _updateCurrentWordIndex();
    checkForGameEnd();
    currentWordIndex++;
    if (gameStatus == WordleGameStatus.inProgress) {
      solutionCopy = Word.fromStr(solution.wordString);
      possibleWords = await _getWords();
      isLoading = false;
    } else {
      isLoading = false;
    }
    notifyListeners();
  }

  Future<List<Word>> _getStateFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    var board = List.generate(
        6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child('wordle/saves/$uid').get();
    if (snapshot.value == null) {
      return board;
    }

    final List<String> words =
        List<String>.from(snapshot.value as List<dynamic>);
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      for (var j = 0; j < word.length; j++) {
        final letter = word[j];
        board[i].letters[j] = Letter(letter: letter);
      }
    }

    return board;
  }

  // update currentWordIndex to the first empty word
  void _updateCurrentWordIndex() {
    currentWordIndex = board.indexWhere((element) =>
            element.letters.indexWhere((element) => element.letter.isEmpty) !=
            -1) -
        1;
  }

  void _saveGameState() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    ref.child('wordle/saves/$uid').set(_convertBoardToWords());
  }

  List<String> _convertBoardToWords() {
    // convert board to list of words
    // and remove emtpy strings
    final words = board.map((e) => e.wordString).toList();
    words.removeWhere((element) => element.isEmpty);
    return words;
  }

  Future<String> _getSolution() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child('wordle/solution').get();
    if (snapshot.value != null) {
      return snapshot.value as String;
    }
    return "error"; // fallback solution if no solution is found in firebase
  }

  Future<List<String>> _getWords() async {
    final data = await rootBundle.loadString('assets/wordle/magyar_szavak.txt');
    List<String> words = data.split('\n');
    // modify all words to lowercase
    words = words.map((e) => e.trim().toLowerCase()).toList();
    return words;
  }

  void onLetterTap(String letter) {
    if (isLoading) {
      return;
    }
    if (gameStatus == WordleGameStatus.inProgress) {
      currentWord.addLetter(letter);
      notifyListeners();
    }
  }

  void onBackspaceTap() {
    if (gameStatus == WordleGameStatus.inProgress) {
      currentWord.removeLetter();
      notifyListeners();
    }
  }

  void onEnterTap() async {
    if (gameStatus == WordleGameStatus.inProgress &&
        !currentWord.letters.contains(Letter.empty())) {
      // check if typed word is in words list
      final word = currentWord.wordString.toLowerCase();
      if (!possibleWords.contains(word)) {
        shouldShowNoWordError = true;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 100), () {
          shouldShowNoWordError = false;
          notifyListeners();
        });
        return;
      }
      gameStatus = WordleGameStatus.submitting;
      solutionCopy = Word.fromStr(solution.wordString);

      for (var i = 0; i < currentWord.letters.length; i++) {
        final currLetter = currentWord.letters[i];

        if (currLetter.letter.toLowerCase() ==
            solution.letters[i].letter.toLowerCase()) {
          final copyIndex = solutionCopy.letters.indexWhere((element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase());
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          currentWord.letters[i] =
              currLetter.copyWith(status: LetterStatus.correct);
        }
      }

      for (var i = 0; i < currentWord.letters.length; i++) {
        final currLetter = currentWord.letters[i];
        if (currLetter.status == LetterStatus.correct) {
          continue;
        }

        if (solutionCopy.letters
            .map((e) => e.letter.toLowerCase())
            .contains(currLetter.letter.toLowerCase())) {
          final copyIndex = solutionCopy.letters.indexWhere((element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase());
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          currentWord.letters[i] =
              currLetter.copyWith(status: LetterStatus.inWord);
        } else {
          currentWord.letters[i] =
              currLetter.copyWith(status: LetterStatus.notInWord);
        }
      }

      // flip the cards and reveal their state
      for (var i = 0; i < currentWord.letters.length; i++) {
        await Future.delayed(
          const Duration(milliseconds: 150),
          () {
            // flip cards
            flipCardControllers[currentWordIndex][i].toggleCard();
            notifyListeners();
          },
        );
      }

      Future.delayed(const Duration(milliseconds: 150 * 5), () {
        for (var i = 0; i < currentWord.letters.length; i++) {
          final currLetter = currentWord.letters[i];
          final letter = keyboardLetters.firstWhere(
            (element) =>
                element.letter.toLowerCase() == currLetter.letter.toLowerCase(),
            orElse: () => Letter.empty(),
          );
          if (letter.status != LetterStatus.correct) {
            keyboardLetters.removeWhere((element) =>
                element.letter.toLowerCase() ==
                currLetter.letter.toLowerCase());
            keyboardLetters.add(currentWord.letters[i]);
          }
        }

        checkForGameEnd();
        currentWordIndex++;
        _saveGameState();
      });
    }
  }

  void checkForGameEnd() {
    if (currentWord.wordString.toLowerCase() ==
        solution.wordString.toLowerCase()) {
      gameStatus = WordleGameStatus.won;
    } else if (currentWordIndex == board.length - 1) {
      gameStatus = WordleGameStatus.lost;
    } else {
      gameStatus = WordleGameStatus.inProgress;
    }
    notifyListeners();
  }

  void _updateBoardTileStates() {
    solutionCopy = Word.fromStr(solution.wordString);
    // determine index of last row of board with letters
    final lastRow = board.indexWhere((element) => element.wordString.isEmpty);

    for (var j = 0; j < lastRow; j++) {
      for (var i = 0; i < board[j].letters.length; i++) {
        final currLetter = board[j].letters[i];

        if (currLetter.letter.toLowerCase() ==
            solution.letters[i].letter.toLowerCase()) {
          final copyIndex = solutionCopy.letters.indexWhere((element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase());
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          board[j].letters[i] =
              currLetter.copyWith(status: LetterStatus.correct);
        }
      }
    
      for (var i = 0; i < board[j].letters.length; i++) {
        final currLetter = board[j].letters[i];
        if (currLetter.status == LetterStatus.correct) {
          continue;
        }

        if (solutionCopy.letters
            .map((e) => e.letter.toLowerCase())
            .contains(currLetter.letter.toLowerCase())) {
          final copyIndex = solutionCopy.letters.indexWhere((element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase());
          if (copyIndex != -1) {
            solutionCopy.letters.removeAt(copyIndex);
          }
          board[j].letters[i] =
              currLetter.copyWith(status: LetterStatus.inWord);
        } else {
          board[j].letters[i] =
              currLetter.copyWith(status: LetterStatus.notInWord);
        }
      }

      for (var i = 0; i < board[j].letters.length; i++) {
        shouldCardBeFlipped[j][i] = true;
        notifyListeners();
      }
    }
  }

  void _updateKeyboardTiles() {
    final lastRow = board.indexWhere((element) => element.wordString.isEmpty);

    for (var j = 0; j < lastRow; j++) {
      for (var i = 0; i < board[j].letters.length; i++) {
        final currLetter = board[j].letters[i];
        final letter = keyboardLetters.firstWhere(
          (element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase(),
          orElse: () => Letter.empty(),
        );
        if (letter.status != LetterStatus.correct) {
          keyboardLetters.removeWhere((element) =>
              element.letter.toLowerCase() == currLetter.letter.toLowerCase());
          keyboardLetters.add(board[j].letters[i]);
        }
      }
    }
    notifyListeners();
  }
}
