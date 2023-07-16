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
  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<SlowQuizViewModel>(context, listen: false).initListeners();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.answers[0].teamNum}. csapat válaszai'),
      ),
      body: ListView.builder(
        itemCount: widget.answers.length,
        itemBuilder: (context, index) {
          return answerCorrectionBlock(index);
        },
      ),
    );
  }

  Widget answerCorrectionBlock(int index) {
    return Column(
      children: [
        Text(
          '${index + 1}. kérdésre érkezett válaszok:',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.answers.length,
          itemBuilder: (context, innerIndex) {
            return ListTile(
              title: Text(widget.answers[innerIndex].answers[index]),
            );
          },
        ),
      ],
    );
  }
}
