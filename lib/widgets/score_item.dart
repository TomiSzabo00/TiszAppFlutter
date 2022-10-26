import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/score_data.dart';

class ScoreItem extends StatelessWidget {
  final Score scoreData;

  const ScoreItem({super.key, required this.scoreData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              scoreData.name,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: (MediaQuery.of(context).size.width - 120 - 20 - 20) / 4,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              scoreData.score1.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: (MediaQuery.of(context).size.width - 120 - 20 - 20) / 4,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              scoreData.score2.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: (MediaQuery.of(context).size.width - 120 - 20 - 20) / 4,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              scoreData.score3.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: (MediaQuery.of(context).size.width - 120 - 20 - 20) / 4,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              scoreData.score4.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
