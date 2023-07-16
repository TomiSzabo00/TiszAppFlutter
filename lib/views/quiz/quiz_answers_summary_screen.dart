import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/slow_quiz_viewmodel.dart';

class QuizAnswersSummaryScreen extends StatefulWidget {
  const QuizAnswersSummaryScreen({
    Key? key,
    required this.answers,
  }) : super(key: key);

  final List<QuizAnswer> answers;

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
    final viewModel = context.watch<SlowQuizViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.answers[0].teamNum}. csapat válaszai'),
      ),
      body: ListView.builder(
        itemCount: widget.answers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.answers[index].author),
            subtitle: Text(widget.answers[index].answers.join(', ')),
            trailing: Text(widget.answers[index].teamNum.toString()),
          );
        },
      ),
    );
  }
}
