import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';

class QuizTile extends StatelessWidget {
  const QuizTile({
    Key? key,
    required this.teamNUm,
    required this.index,
  }) : super(key: key);

  final int? teamNUm;
  final int index;

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
      child: Center(
        child: Text(
            teamNUm == null
                ? 'Még nics $index. jelentkező'
                : '$teamNUm. csapat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: teamNUm == null ? FontWeight.normal : FontWeight.bold,
              color: _getTextColor(isDarkTheme: isDarkTheme),
            )),
      ),
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
