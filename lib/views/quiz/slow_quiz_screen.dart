import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/slow_quiz_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class SlowQuizScreen extends StatefulWidget {
  const SlowQuizScreen({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  final bool isAdmin;

  @override
  State<SlowQuizScreen> createState() => _SlowQuizScreenState();
}

class _SlowQuizScreenState extends State<SlowQuizScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SlowQuizViewModel>(context, listen: false).initListeners();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<SlowQuizViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: viewModel.isSummary
            ? const Text('Összefoglaló')
            : const Text('Lassú kvíz'),
        actions: [
          () {
            if (viewModel.isSummary) {
              return IconButton(
                onPressed: () {
                  showAreYouSureDialog();
                },
                icon: const Icon(Icons.delete),
              );
            } else {
              return const SizedBox.shrink();
            }
          }(),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
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
          child: SingleChildScrollView(
            child: () {
              if (widget.isAdmin) {
                if (viewModel.numberOfQuestions == 0 && !viewModel.isSummary) {
                  return adminNotStaertedScreen(isDarkTheme);
                } else if (viewModel.numberOfQuestions > 0 &&
                    !viewModel.isSummary) {
                  return adminDidStartScreen(isDarkTheme);
                } else if (viewModel.isSummary) {
                  return adminSummaryScreen();
                } else {
                  return const Text('Hiba történt!');
                }
              } else {
                return const Text('Nem vagy admin!');
              }
            }(),
          ),
        ),
      ),
    );
  }

  Widget adminNotStaertedScreen(bool isDarkTheme) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          'A kvíz még nem kezdődött el!',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 60,
        ),
        const Text('Hány kérdés legyen a kvízben?',
            style: TextStyle(fontSize: 16)),
        const SizedBox(
          height: 20,
        ),
        counter(isDarkTheme),
        const SizedBox(
          height: 20,
        ),
        () {
          if (Provider.of<SlowQuizViewModel>(context, listen: false).counter >
              0) {
            return Button3D(
              width: 150,
              onPressed: () {
                Provider.of<SlowQuizViewModel>(context, listen: false)
                    .startQuiz();
              },
              child: Text(
                'Kvíz indítása',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }(),
      ],
    );
  }

  Widget adminDidStartScreen(bool isDarkTheme) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          'A kvíz folyamatban van!',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Kérdések száma: ${Provider.of<SlowQuizViewModel>(context, listen: false).numberOfQuestions}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 60,
        ),
        Button3D(
          width: 150,
          onPressed: () {
            Provider.of<SlowQuizViewModel>(context, listen: false).stopQuiz();
          },
          child: Text(
            'Kvíz leállítása',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Button3D(
          width: 200,
          onPressed: () {
            Provider.of<SlowQuizViewModel>(context, listen: false)
                .resetAnswers();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AutoSizeText(
              'Válaszok visszaállítása',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
              ),
              maxLines: 1,
              minFontSize: 10,
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Button3D(
          width: 150,
          onPressed: () {
            Provider.of<SlowQuizViewModel>(context, listen: false).deleteQuiz();
          },
          child: Text(
            'Kvíz törlése',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
            ),
          ),
        ),
      ],
    );
  }

  Widget adminSummaryScreen() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Beérkezett válaszok:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: () {
              if (Provider.of<SlowQuizViewModel>(context, listen: false)
                  .answersByTeams
                  .isNotEmpty) {
                return ListView.builder(
                  itemCount:
                      Provider.of<SlowQuizViewModel>(context, listen: false)
                          .answersByTeams
                          .length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${Provider.of<SlowQuizViewModel>(context, listen: false).answersByTeams[index]}. csapat',
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        '${Provider.of<SlowQuizViewModel>(context, listen: false).answersByTeams[index].length} darab válasz',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                );
              } else {
                return const Text('Nem érkezett válasz :(');
              }
            }(),
          ),
        ],
      ),
    );
  }

  Widget counter(bool isDarkTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Button3D(
          width: 50,
          height: 50,
          onPressed: () {
            Provider.of<SlowQuizViewModel>(context, listen: false)
                .decrementCounter();
          },
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 20,
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Container(
          width: 80,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            backgroundBlendMode: BlendMode.dstATop,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${Provider.of<SlowQuizViewModel>(context).counter}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Button3D(
          width: 50,
          height: 50,
          onPressed: () {
            Provider.of<SlowQuizViewModel>(context, listen: false)
                .incrementCounter();
          },
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 20,
              color: isDarkTheme
                  ? CustomColor.btnTextNight
                  : CustomColor.btnTextDay,
            ),
          ),
        ),
      ],
    );
  }

  void showAreYouSureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Biztosan törölni szeretnéd a kvízt?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Mégse'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<SlowQuizViewModel>(context, listen: false)
                    .deleteQuiz();
                Navigator.pop(context);
              },
              child: const Text('Igen'),
            ),
          ],
        );
      },
    );
  }
}
