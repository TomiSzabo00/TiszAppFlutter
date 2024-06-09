import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/wordle/letter.dart';
import 'package:tiszapp_flutter/models/wordle/letter_status.dart';
import 'package:tiszapp_flutter/models/wordle/wordle_game_status.dart';
import 'package:tiszapp_flutter/viewmodels/wordle_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/wordle/board.dart';
import 'package:tiszapp_flutter/widgets/wordle/board_tile.dart';
import 'package:tiszapp_flutter/widgets/wordle/keyboard.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  WordleScreenState createState() => WordleScreenState();
}

class WordleScreenState extends State<WordleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WordleViewModel>(context, listen: false).init();
    });
  }

  @override
  void activate() {
    super.activate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WordleViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<WordleViewModel>();
    AnimationController? localAnimationController;
    return PopScope(
      onPopInvoked: (_) {
        if (localAnimationController?.isAnimating == true) {
          localAnimationController?.reverse();
        } else if (localAnimationController?.isCompleted == true) {
          localAnimationController?.reset();
        }

      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wordle'),
          actions: [
            // add info button
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: 'Játékszabályok',
              onPressed: () => _showTutorial(),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isDarkTheme ? const AssetImage("images/bg2_night.png") : const AssetImage("images/bg2_day.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                            ),
                          ),
                        );
                      }
                    })(),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0, left: 12, right: 12, top: 10),
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
                          onAnimationControllerInit: (controller) => localAnimationController = controller,
                          displayDuration: const Duration(seconds: 2),
                        );
                      });
                    } else if (viewModel.gameStatus == WordleGameStatus.won) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message: "Gratulálok, nyertél! Nézz vissza holnap!",
                            textScaleFactor: 1.3,
                          ),
                          onAnimationControllerInit: (controller) => localAnimationController = controller,
                          displayDuration: const Duration(seconds: 10),
                          dismissType: DismissType.onSwipe,
                        );
                      });
                    } else if (viewModel.gameStatus == WordleGameStatus.lost) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            icon: const Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Color(0x15000000),
                              size: 120,
                            ),
                            message:
                                "Sajnos vesztettél! A megoldás a ${viewModel.solution.wordString.toUpperCase()} volt.",
                            textScaleFactor: 1.2,
                          ),
                          onAnimationControllerInit: (controller) => localAnimationController = controller,
                          displayDuration: const Duration(seconds: 10),
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
      ),
    );
  }

  void _showTutorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              children: [
                Column(
                  children: [
                    _tutorialTitle(),
                    _tutorialDescription(),
                    _examples(),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _tutorialTitle() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        "Játékszabályok",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tutorialDescription() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        """A Wordle egy szókirakós játék, amelyben a célod egy magyar szó kitalálása, amely jelen esetben sokszor kötődik a táborhoz.

A játékban 5 betűből álló szavakat kell kitalálnod. Erre összesen 6 lehetőséged van. Ha a hatodik próbálkozásod is rossz, akkor vesztettél.

A kitalálásban segítséget nyújtanak a betűk színei. Ha a tippedet beküldöd, akkor a betűi elszíneződnek.
A zöld szín azt jelenti, hogy a megoldásban is pont azon a helyen szerepel a betű, mint a tippedben.
A sárga azt jelenti, hogy a megoldásban szerepel a betű, de nem a tippedben megjelenő helyen.
Ha a betű szürke lesz, akkor nincs a megoldásban benne.

Egy betű szerepleht többször a megoldásban, erre figyelj, és ennek megfelelően lesz színezve is a tippedben is. Lentebb láthatsz példákat erre.
Egy betűt több tippben is felhasználhatsz, függetlenül attól, hogy szerepel-e a megoldásban, vagy sem. Ez sokszor tud jó taktika lenni.

Minden nap 1 feladvány lesz, így ha egy nap kitaláltad a megfejtést, vagy elhasználtad az összes tippelési lehetőségedet, akkor aznap már nem tudsz többet játszani.
Másnap viszont újra próbálkozhatsz.

A játék nem pontban éjfélkor frissül, hanem később, a hajnali órákban, így nem érdemes ébren megvárni az új feladványt :)""",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _examples() {
    return Column(
      children: [
        _oneLetterInWord(),
        _someLettersCorrect(),
        _sameLetterTwiceOneCorrect(),
        _sameLetterTwice(),
        _solution(),
      ],
    );
  }

  Widget _oneLetterInWord() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "A megoldásban van valahol egy 'R' betű, de nem a második helyen. A többi betű nem szerepel a megoldásban.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "P",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "R",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "Ó",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "B",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "A",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _someLettersCorrect() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "A megoldás második és negyedik betűje 'Á' és 'O', de a többi betű nincs benne.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "T",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "Á",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "K",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "O",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "L",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sameLetterTwice() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Itt viszont az látható, hogy mindkét 'S' betű színes lett, tehát kettő is van a magoldásban. Az egyik az utolsó helyen, de a másik nem az utolsó előttin.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "F",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "R",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "I",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "S",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "S",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sameLetterTwiceOneCorrect() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Itt a lényeg a két 'O' betű, ugyanis csak az egyikre jelzi, hogy szerepelne a megoldásban. Ez azért van, mert csak egy 'O' betű van a megoldásban, ami nem az első, se nem a harmadik helyen áll.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "O",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "R",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "O",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "S",
                      status: LetterStatus.inWord,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "Z",
                      status: LetterStatus.notInWord,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _solution() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "A megoldás a SÁROS volt.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "S",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "Á",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "R",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "O",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BoardTile(
                    letter: Letter(
                      letter: "S",
                      status: LetterStatus.correct,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
