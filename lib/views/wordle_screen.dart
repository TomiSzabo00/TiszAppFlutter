import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/wordle/keyboard.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
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
    AnimationController localAnimationController;
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
            ),
            // Consumer to listen to shouldShowError in the viewmodel
            Consumer<WordleViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.shouldShowNoWordError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showTopSnackBar(
                      Overlay.of(context)!,
                      const CustomSnackBar.error(
                        message: "Nincs ilyen magyar szó!",
                      ),
                      onAnimationControllerInit: (controller) =>
                          localAnimationController = controller,
                      displayDuration: const Duration(seconds: 2),
                    );
                  });
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
