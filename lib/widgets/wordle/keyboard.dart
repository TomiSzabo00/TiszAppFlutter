import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/wordle/letter.dart';

const keys = [
  ["Í", "Ö", "Ü", "Ó", "Ő", "Ú", "É", "Á", "Ű"], // ö ü ó ő ú é á ű í
  ["Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"], // 12
  ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
  ["ENTER", "Y", "X", "C", "V", "B", "N", "M", "DEL"],
];

class Keyboard extends StatelessWidget {
  const Keyboard({
    Key? key,
    required this.onLetterPressed,
    required this.onEnterPressed,
    required this.onDeletePressed,
    required this.letters,
  }) : super(key: key);

  final void Function(String) onLetterPressed;
  final VoidCallback onEnterPressed;
  final VoidCallback onDeletePressed;
  final Set<Letter> letters;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map(
                (letter) {
                  if (letter == "DEL") {
                    return _KeyboardButton.delete(onTap: onDeletePressed);
                  } else if (letter == "ENTER") {
                    return _KeyboardButton.enter(onTap: onEnterPressed);
                  } else {
                    final letterKey = letters.firstWhere(
                      (element) => element.letter == letter,
                      orElse: () => Letter.empty(),
                    );

                    return _KeyboardButton(
                      onTap: () => onLetterPressed(letter),
                      letter: letter,
                      backgroundColor: letterKey != Letter.empty()
                          ? letterKey.getBackgroundColor(isDarkTheme)
                          : isDarkTheme ? Colors.grey : Colors.white,
                    );
                  }
                },
              ).toList(),
            ),
          )
          .toList(),
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    Key? key,
    this.height = 48,
    this.width = 48,
    this.flex = 1,
    required this.onTap,
    required this.letter,
    required this.backgroundColor,
  }) : super(key: key);

  final double height;
  final double width;
  final int flex;
  final VoidCallback onTap;
  final String letter;
  final Color backgroundColor;

  factory _KeyboardButton.delete({
    required VoidCallback onTap,
  }) {
    return _KeyboardButton(
      width: 56,
      flex: 0,
      onTap: onTap,
      letter: "DEL",
      backgroundColor: Colors.grey,
    );
  }

  factory _KeyboardButton.enter({
    required VoidCallback onTap,
  }) {
    return _KeyboardButton(
      width: 56,
      flex: 0,
      onTap: onTap,
      letter: "ENTER",
      backgroundColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 2,
          ),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
