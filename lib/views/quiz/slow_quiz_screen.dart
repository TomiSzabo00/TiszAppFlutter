import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/slow_quiz_viewmodel.dart';
import 'package:tiszapp_flutter/views/quiz/quiz_answers_summary_screen.dart';
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
        title: const Text('Lassú kvíz'),
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
            colorFilter: widget.isAdmin
                ? null
                : ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.dstATop),
          ),
        ),
        child: Center(
          //child: SingleChildScrollView(
          child: () {
            if (widget.isAdmin) {
              if (viewModel.numberOfQuestions == 0) {
                return adminNotStaertedScreen(isDarkTheme);
              } else {
                return adminSummaryScreen(isDarkTheme);
              }
            } else {
              if (viewModel.numberOfQuestions == 0) {
                return notStartedUserScreen();
              } else if (viewModel.numberOfQuestions > 0 &&
                  !viewModel.isSummary &&
                  !viewModel.didSendAnswers) {
                return didStartUserScreen(viewModel, isDarkTheme);
              } else {
                return didSendUserScreen();
              }
            }
          }(),
          //),
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

  Widget adminSummaryScreen(bool isDarkTheme) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Provider.of<SlowQuizViewModel>(context, listen: false)
                          .isSummary
                      ? 'A kvíz megállt.'
                      : 'A kvíz folyamatban van!',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Kérdések száma: ${Provider.of<SlowQuizViewModel>(context, listen: false).numberOfQuestions}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 20,
                ),
                answersWidget(),
                const SizedBox(
                  height: 20,
                ),
                Button3D(
                  width: MediaQuery.of(context).size.width - 40,
                  onPressed: () {
                    Provider.of<SlowQuizViewModel>(context, listen: false)
                        .toggleQuizState();
                  },
                  child: Text(
                    Provider.of<SlowQuizViewModel>(context, listen: false)
                            .isSummary
                        ? 'Kvíz elindítása'
                        : 'Kvíz megállítása',
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
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button3D(
                      width: 140,
                      onPressed: () {
                        Provider.of<SlowQuizViewModel>(context, listen: false)
                            .resetAnswers();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AutoSizeText(
                          'Válaszok törlése',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                          ),
                          maxLines: 1,
                          minFontSize: 6,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Button3D(
                      width: 140,
                      onPressed: () {
                        Provider.of<SlowQuizViewModel>(context, listen: false)
                            .deleteQuiz();
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
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget answersWidget() {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Beérkezett válaszok:',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
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
                              '${Provider.of<SlowQuizViewModel>(context, listen: false).answersByTeams[index][0].teamNum}. csapat'),
                          subtitle: Text(
                              '${Provider.of<SlowQuizViewModel>(context, listen: false).answersByTeams[index].length} darab válasz'),
                          trailing: Text(
                              '${Provider.of<SlowQuizViewModel>(context, listen: false).getScoreFor(index)}/${Provider.of<SlowQuizViewModel>(context, listen: false).numberOfQuestions} pont'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      QuizAnswersSummaryScreen(
                                        viewModel:
                                            Provider.of<SlowQuizViewModel>(
                                          context,
                                          listen: false,
                                        ),
                                        index: index,
                                      )),
                            );
                          },
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
        ),
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

  Widget notStartedUserScreen() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'A kvíz még nem kezdődött el!',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget didStartUserScreen(SlowQuizViewModel viewModel, bool isDarkTheme) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width - 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            () {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: viewModel.controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: viewModel.controllers[index],
                      decoration: InputDecoration(
                        labelText: '${index + 1}. kérdésre a válaszod',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              );
            }(),
            const SizedBox(
              height: 20,
            ),
            Button3D(
              width: 200,
              onPressed: () {
                showAreYouSureSendDialog();
              },
              child: Text(
                'Válaszok elküldése',
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
        ),
      ),
    );
  }

  Widget didSendUserScreen() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'Már elküldted a válaszodat, vagy lezáródott a kvíz!',
        style: TextStyle(fontSize: 20),
      ),
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

  void showAreYouSureSendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Biztosan elküldöd a válaszokat?'),
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
                    .sendAnswers();
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
