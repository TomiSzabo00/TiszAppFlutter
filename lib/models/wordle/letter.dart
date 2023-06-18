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

  Color get backgroundColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.transparent;
      case LetterStatus.inWord:
        return WordleColors.inWordColor;
      case LetterStatus.notInWord:
        return WordleColors.notInWordColor;
      case LetterStatus.correct:
        return WordleColors.correctColor;
    }
  }

  Color get borderColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.grey;
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
