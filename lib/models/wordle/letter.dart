import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/wordle/letter_status.dart';

class Letter extends Equatable {
  final String letter;
  final LetterStatus status;

  const Letter({required this.letter, this.status = LetterStatus.initial});

  factory Letter.empty() {
    return const Letter(letter: "");
  }

  Color getBackgroundColor(bool isDarkTheme) {
    switch (status) {
      case LetterStatus.initial:
        return isDarkTheme ? Colors.grey.withOpacity(0.5) : Colors.black.withOpacity(0.3);
      case LetterStatus.inWord:
        return isDarkTheme ? WordleColors.inWordColorDark : WordleColors.inWordColorLight;
      case LetterStatus.notInWord:
        return isDarkTheme ? WordleColors.notInWordColorDark : WordleColors.notInWordColorLight;
      case LetterStatus.correct:
        return isDarkTheme ? WordleColors.correctColorDark : WordleColors.correctColorLight;
    }
  }

  Color getBorderColor(bool isDarkTheme) {
    switch (status) {
      case LetterStatus.initial:
        return isDarkTheme ? Colors.grey : Colors.black;
      default:
        return Colors.transparent;
    }
  }

  Letter copyWith({String? letter, LetterStatus? status}) {
    return Letter(
      letter: letter ?? this.letter,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [letter, status];
}
