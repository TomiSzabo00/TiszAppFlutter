import 'package:flutter/material.dart';

import '../../models/wordle/letter.dart';

class BoardTile extends StatelessWidget {
  const BoardTile({Key? key, required this.letter}) : super(key: key);

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter.backgroundColor,
        border: Border.all(color: letter.borderColor),
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
