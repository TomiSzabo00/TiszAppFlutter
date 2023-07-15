import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_state.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/quiz_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/quiz/quiz_tile.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  final bool isAdmin;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      Provider.of<QuizViewModel>(context, listen: false)
          .subscribeToQuizStateChanges();
      Provider.of<QuizViewModel>(context, listen: false)
          .subscribeToSignalEventsAsAdmin();
      Provider.of<QuizViewModel>(context, listen: false).setNumberOfTeams();
    } else {
      Provider.of<QuizViewModel>(context, listen: false)
          .subscribeToQuizStateChanges();
      Provider.of<QuizViewModel>(context, listen: false)
          .subscribeToSignalEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<QuizViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: widget.isAdmin
          ? adminScreen(viewModel, isDarkTheme)
          : userScreen(viewModel),
    );
  }

  Widget userScreen(QuizViewModel viewModel) {
    return LayoutBuilder(
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
    );
  }

  Widget adminScreen(QuizViewModel viewModel, bool isDarkTheme) {
    if (viewModel.state == QuizState.disabled) {
      return _disdbledScreen(viewModel, isDarkTheme);
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.numberOfTeams,
              itemBuilder: (context, index) => QuizTile(
                teamNUm: viewModel.getTeamNum(index),
                index: index + 1,
                timeStamp: viewModel.timeDiffernceFromPrevious(index: index),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Button3D(
                onPressed: () => viewModel.reset(),
                child: Text(
                  'Visszaállítás',
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkTheme
                          ? CustomColor.btnTextNight
                          : CustomColor.btnTextDay),
                ),
              ),
              Button3D(
                onPressed: () => viewModel.disable(),
                child: Text(
                  'Letiltás',
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkTheme
                          ? CustomColor.btnTextNight
                          : CustomColor.btnTextDay),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _disdbledScreen(QuizViewModel viewModel, bool isDarkTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'A quiz jelenleg le van tiltva.',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20, width: double.infinity),
        Button3D(
          onPressed: () => viewModel.reset(),
          child: Text(
            'Engedélyezés',
            style: TextStyle(
                fontSize: 15,
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay),
          ),
        ),
      ],
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
