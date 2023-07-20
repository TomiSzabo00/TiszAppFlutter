import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/scores/score_data.dart';
import 'package:tiszapp_flutter/viewmodels/scores_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/score_item.dart';
import 'package:provider/provider.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ScoresViewModel>(context, listen: false).getScores();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<ScoresViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontállás'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                isDarkTheme ? 'images/bg2_night.png' : 'images/bg2_day.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 100,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDarkTheme ? Colors.black : Colors.white),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Csapatok pontjai',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ScoreItem(
              scoreData: Score(
                  author: "",
                  name: 'Program neve',
                  scores: List.generate(
                      viewModel.numberOfTeams, (index) => index + 1)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.scores.length,
                itemBuilder: (context, index) {
                  return ScoreItem(
                    scoreData: viewModel.scores[index],
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ScoreItem(
              scoreData: viewModel.totalScore,
              isSum: true,
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
