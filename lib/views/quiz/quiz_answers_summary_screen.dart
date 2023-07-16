import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/slow_quiz_viewmodel.dart';

class QuizAnswersSummaryScreen extends StatefulWidget {
  const QuizAnswersSummaryScreen({
    Key? key,
    required this.viewModel,
    required this.index,
  }) : super(key: key);

  final SlowQuizViewModel viewModel;
  final int index;

  List<QuizAnswer> get answers => viewModel.answersByTeams[index];

  @override
  QuizAnswersSummaryScreenState createState() =>
      QuizAnswersSummaryScreenState();
}

class QuizAnswersSummaryScreenState extends State<QuizAnswersSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.answers[0].teamNum}. csapat válaszai'),
      ),
      body: ListView.builder(
        itemCount: widget.answers.length,
        itemBuilder: (context, index) {
          return answerCorrectionBlock(widget.viewModel, index, widget.index);
        },
      ),
    );
  }

  Widget answerCorrectionBlock(
      SlowQuizViewModel viewModel, int index, int teamNum) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Container(
        decoration: BoxDecoration(
          color: viewModel
              .getBackgroundForAnswers(teamNum, index)
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                '${index + 1}. kérdésre érkezett válaszok:',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.answers.length,
              itemBuilder: (context, innerIndex) {
                return ListTile(
                  title: Text(widget.answers[innerIndex].answers[index]),
                );
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10)),
                    ),
                    width: double.infinity,
                    child: IconButton(
                      onPressed: () {
                        viewModel.setAnswersCorrect(index, teamNum);
                        setState(() {});
                      },
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    color: Colors.orange[100],
                    child: IconButton(
                      onPressed: () {
                        viewModel.setAnswersPartiallyCorrect(index, teamNum);
                        setState(() {});
                      },
                      icon: const Icon(Icons.iso),
                      color: Colors.orange,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10)),
                    ),
                    width: double.infinity,
                    child: IconButton(
                      onPressed: () {
                        viewModel.setAnswersIncorrect(index, teamNum);
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
