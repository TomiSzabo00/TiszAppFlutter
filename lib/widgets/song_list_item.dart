import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'package:tiszapp_flutter/views/songs/songs_detail_screen.dart';

class SongListItem extends StatelessWidget {
  const SongListItem({Key? key, required this.song}) : super(key: key);
  final Song song;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(song.name),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => SongsDetailScreen(song: song)),
        );
      },
      trailing: Icon(
        Icons.chevron_right,
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
    );
  }
}
