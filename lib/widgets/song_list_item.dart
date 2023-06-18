import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/song_data.dart';

class SongListItem extends StatelessWidget {
  const SongListItem({Key? key, required this.song}) : super(key: key);
  final Song song;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(song.name),
      onTap: () {
        Navigator.pushNamed(context, '/Daloskönyv/Részlet', arguments: song);
      },
      trailing: Icon(
        Icons.chevron_right,
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
    );
  }
}
