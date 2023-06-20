import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_state.dart';
import 'package:tiszapp_flutter/viewmodels/quiz_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<QuizViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuizViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => MaterialButton(
          minWidth: constraints.maxWidth,
          height: constraints.maxHeight,
          color: () {
            if (viewModel.state == QuizState.enabled) {
              return Colors.green;
            } else if (viewModel.state == QuizState.teammateDidSend) {
              return Colors.yellow;
            } else if (viewModel.state == QuizState.didSend) {
              return Colors.orange;
            } else {
              return Colors.grey;
            }
          }(),
          splashColor: viewModel.canSend
              ? Theme.of(context).splashColor
              : Colors.transparent,
          highlightColor: viewModel.canSend
              ? Theme.of(context).highlightColor
              : Colors.transparent,
          onPressed: () => viewModel.canSend ? viewModel.send() : null,
          onLongPress: () => _showDontCheatDialog(context),
        ),
      ),
    );
  }

  void _showDontCheatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajjaj...'),
        content: const Text('Ne tartsd az ujjad a gombon! Az csalás :)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Oké'),
          ),
        ],
      ),
    );
  }
}
