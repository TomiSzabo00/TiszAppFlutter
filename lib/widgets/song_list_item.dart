import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/song_data.dart';

class SongListItem extends StatelessWidget {
  const SongListItem({Key? key, required this.song}) : super(key: key);
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(song.name),
      onTap: () {
        Navigator.pushNamed(context, '/Daloskönyv/Részlet', arguments: song);
      },
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
