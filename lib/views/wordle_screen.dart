import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/wordle/keyboard.dart';
import '../models/wordle/letter.dart';
import '../models/wordle/word.dart';
import '../viewmodels/wordle_viewmodel.dart';
import '../widgets/wordle/board.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({Key? key}) : super(key: key);

  @override
  WordleScreenState createState() => WordleScreenState();
}

class WordleScreenState extends State<WordleScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WordleViewModel>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WordleViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Board(board: viewModel.board, flipCardKeys: viewModel.flipCardKeys),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Keyboard(
                onLetterPressed: viewModel.onLetterTap,
                onEnterPressed: viewModel.onEnterTap,
                onDeletePressed: viewModel.onBackspaceTap,
                letters: viewModel.keyboardLetters,
              ),
            )
          ],
        ),
      ),
    );
  }
}
