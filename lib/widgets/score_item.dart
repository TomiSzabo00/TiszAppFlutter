import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/score_data.dart';

class ScoreItem extends StatelessWidget {
  final Score scoreData;
  final bool isSum;

  const ScoreItem({super.key, required this.scoreData, this.isSum = false});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 120,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSum
                  ? (isDarkTheme
                      ? CustomColor.btnFaceNight
                      : CustomColor.btnFaceDay)
                  : CustomColor.semiTransparentWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  scoreData.name,
                  style: TextStyle(
                    color: isSum
                        ? (isDarkTheme
                            ? CustomColor.btnTextNight
                            : CustomColor.btnTextDay)
                        : null,
                  ),
                )),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scoreData.scores.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: (MediaQuery.of(context).size.width -
                          120 -
                          10 -
                          scoreData.scores.length * 10) /
                      scoreData.scores.length,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSum
                        ? (isDarkTheme
                            ? CustomColor.btnFaceNight
                            : CustomColor.btnFaceDay)
                        : CustomColor.semiTransparentWhite,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      scoreData.scores[index].toString(),
                      style: TextStyle(
                        color: isSum
                            ? (isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
