import 'package:auto_size_text/auto_size_text.dart';
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
                  : (isDarkTheme ? Colors.black : Colors.white),
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
            child: Center(
              child: AutoSizeText(
                scoreData.name,
                maxLines: 2,
                minFontSize: 8,
                style: TextStyle(
                  color: isSum
                      ? (isDarkTheme
                          ? CustomColor.btnTextNight
                          : CustomColor.btnTextDay)
                      : null,
                ),
              ),
            ),
          ),
          Flexible(
            child: Row(
              children: List.generate(
                scoreData.scores.length,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSum
                          ? (isDarkTheme
                              ? CustomColor.btnFaceNight
                              : CustomColor.btnFaceDay)
                          : (isDarkTheme ? Colors.black : Colors.white),
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
                    child: AutoSizeText(
                      scoreData.scores[index].toString(),
                      maxLines: 1,
                      minFontSize: 4,
                      style: TextStyle(
                        color: isSum
                            ? (isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
