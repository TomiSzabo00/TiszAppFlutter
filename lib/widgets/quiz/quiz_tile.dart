import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';

class QuizTile extends StatelessWidget {
  const QuizTile({
    Key? key,
    required this.teamNUm,
    required this.index,
    required this.timeStamp,
  }) : super(key: key);

  final int? teamNUm;
  final int index;
  final String? timeStamp;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getColor(context: context, isDarkTheme: isDarkTheme),
        borderRadius: BorderRadius.circular(20),
      ),
      child: () {
        if (teamNUm == null) {
          return _noSignal(index);
        } else {
          return _signal(teamNUm!, timeStamp, isDarkTheme);
        }
      }(),
    );
  }

  Widget _noSignal(int index) {
    return Center(
      child: Text(
        'Még nincs $index. jelentkező',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _signal(int teamNum, String? timeStamp, bool isDarkTheme) {
    return Column(
      children: [
        Text('$teamNUm. csapat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getTextColor(isDarkTheme: isDarkTheme),
            )),
        () {
          if (timeStamp != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                timeStamp,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: _getTextColor(isDarkTheme: isDarkTheme),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }(),
      ],
    );
  }

  Color _getColor({required BuildContext context, required bool isDarkTheme}) {
    if (teamNUm == null) {
      return isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!;
    } else {
      return isDarkTheme ? CustomColor.btnFaceNight : CustomColor.btnFaceDay;
    }
  }

  Color _getTextColor({required bool isDarkTheme}) {
    if (teamNUm == null) {
      return isDarkTheme ? Colors.white : Colors.black;
    } else {
      return isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay;
    }
  }
}
