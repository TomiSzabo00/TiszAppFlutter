import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/hazas_parbaj_data.dart';

class HazasTile extends StatelessWidget {
  const HazasTile({Key? key, required this.data}) : super(key: key);

  final HazasParbajData data;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text('${data.name1} és ${data.name2}',
            style: TextStyle(
              color: isDarkTheme ? Colors.green[50] : Colors.green[700],
            )),
        subtitle: Text('${data.team}. csapat',
            style: TextStyle(
              color: isDarkTheme ? Colors.green[100] : Colors.green[600],
            )),
        tileColor: isDarkTheme ? Colors.green[600] : Colors.green[100],
      ),
    );
  }
}
