import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/wordle/wordle_game_status.dart';
import 'package:tiszapp_flutter/viewmodels/wordle_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/wordle/board.dart';
import 'package:tiszapp_flutter/widgets/wordle/keyboard.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<WordleViewModel>();
    // ignore: unused_local_variable
    AnimationController localAnimationController;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: isDarkTheme
                ? const AssetImage("images/bg2_night.png")
                : const AssetImage("images/bg2_day.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: (() {
                    if (viewModel.isLoading) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text(
                            "Betöltés...",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Scrollbar(
                        thumbVisibility: true,
                        thickness: 8.0,
                        radius: const Radius.circular(20.0),
                        child: SingleChildScrollView(
                          child: Board(
                            board: viewModel.board,
                            flipCardControllers: viewModel.flipCardControllers,
                            flipped: viewModel.shouldCardBeFlipped,
                          ),
                        ),
                      );
                    }
                  })(),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(32.0),
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
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: "Nincs ilyen magyar szó!",
                        ),
                        onAnimationControllerInit: (controller) =>
                            localAnimationController = controller,
                        displayDuration: const Duration(seconds: 2),
                      );
                    });
                  } else if (viewModel.gameStatus == WordleGameStatus.won) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showTopSnackBar(
                        Overlay.of(context),
                        const CustomSnackBar.success(
                          message: "Gratulálok, nyertél!",
                          textScaleFactor: 1.3,
                        ),
                        onAnimationControllerInit: (controller) =>
                            localAnimationController = controller,
                        displayDuration: const Duration(seconds: 3),
                        dismissType: DismissType.onSwipe,
                      );
                    });
                  } else if (viewModel.gameStatus == WordleGameStatus.lost) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showTopSnackBar(
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          icon: Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Color(0x15000000),
                            size: 120,
                          ),
                          message: "Sajnos vesztettél!",
                          textScaleFactor: 1.3,
                        ),
                        onAnimationControllerInit: (controller) =>
                            localAnimationController = controller,
                        displayDuration: const Duration(seconds: 3),
                        dismissType: DismissType.onSwipe,
                      );
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
