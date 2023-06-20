import 'package:flutter/material.dart';

import '../../models/wordle/letter.dart';

class BoardTile extends StatelessWidget {
  const BoardTile({Key? key, required this.letter}) : super(key: key);

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // width: 48,
      // height: 48,
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter.getBackgroundColor(isDarkTheme),
        border: Border.all(
          color: letter.getBorderColor(isDarkTheme),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        letter.letter,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
