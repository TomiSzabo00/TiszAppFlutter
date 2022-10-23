import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/score_data.dart';

class ScoreItem extends StatelessWidget {
  final Score scoreData;

  const ScoreItem({super.key, required this.scoreData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            scoreData.name,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            scoreData.score1.toString(),
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            scoreData.score2.toString(),
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            scoreData.score3.toString(),
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            scoreData.score4.toString(),
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
