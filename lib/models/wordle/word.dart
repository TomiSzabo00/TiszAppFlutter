import 'package:equatable/equatable.dart';
import 'package:tiszapp_flutter/models/wordle/letter.dart';

class Word extends Equatable {
  final List<Letter> letters;

  const Word({required this.letters});

  factory Word.fromStr(String word) {
    return Word(
      letters: word.split("").map((e) => Letter(letter: e)).toList(),
    );
  }

  String get wordString {
    return letters.map((e) => e.letter).join("");
  }

  void addLetter(String letter) {
    final currIndex = letters.indexWhere((element) => element.letter.isEmpty);
    if (currIndex != -1) {
      letters[currIndex] = Letter(letter: letter);
    }
  }

  void removeLetter() {
    final currIndex = letters.lastIndexWhere((element) => element.letter.isNotEmpty);
    if (currIndex != -1) {
      letters[currIndex] = Letter.empty();
    }
  }

  @override
  List<Object?> get props => [letters];
}