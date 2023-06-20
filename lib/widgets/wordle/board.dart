import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/wordle/letter_status.dart';
import '../../models/wordle/letter.dart';
import '../../models/wordle/word.dart';
import 'board_tile.dart';

class Board extends StatelessWidget {
  const Board({
    Key? key,
    required this.board,
    required this.flipCardControllers,
    required this.flipped,
  }) : super(key: key);

  final List<Word> board;

  final List<List<FlipCardController>> flipCardControllers;
  final List<List<bool>> flipped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: board
          .asMap()
          .map(
            (i, word) => MapEntry(
              i,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: word.letters
                    .asMap()
                    .map(
                      (j, letter) => MapEntry(
                        j,
                        FlipCard(
                          controller: flipCardControllers[i][j],
                          side: flipped[i][j] ? CardSide.BACK : CardSide.FRONT,
                          flipOnTouch: false,
                          direction: FlipDirection.VERTICAL,
                          front: BoardTile(
                            letter: Letter(
                              letter: letter.letter,
                              status: LetterStatus.initial,
                            ),
                          ),
                          back: BoardTile(letter: letter),
                        ),
                      ),
                    )
                    .values
                    .toList(),
              ),
            ),
          )
          .values
          .toList(),
    );
  }
}
