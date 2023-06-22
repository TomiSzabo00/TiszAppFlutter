import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/karaoke/karaoke_data.dart';

class KaraokeTile extends StatelessWidget {
  const KaraokeTile({super.key, required this.data});

  final KaraokeData data;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          data.user.isAdmin ? "${data.user.name} (szerv.)" : data.user.name,
          style: TextStyle(
            color: data.didPlay
                ? isDarkTheme
                    ? Colors.green[50]
                    : Colors.green[700]
                : null,
          ),
        ),
        subtitle: Text(data.music,
            style: TextStyle(
              color: data.didPlay
                  ? isDarkTheme
                      ? Colors.green[100]
                      : Colors.green[600]
                  : null,
            )),
        trailing: () {
          if (data.didPlay) {
            return Icon(
              Icons.check,
              color: isDarkTheme ? Colors.green[100] : Colors.green[700],
            );
          }
        }(),
        tileColor: () {
          if (data.didPlay) {
            return isDarkTheme ? Colors.green[600] : Colors.green[100];
          } else {
            return null;
          }
        }(),
      ),
    );
  }
}
