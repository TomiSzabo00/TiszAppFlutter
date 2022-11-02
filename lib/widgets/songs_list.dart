import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/song_data.dart';
import 'package:tiszapp_flutter/widgets/song_list_item.dart';

class SongsList extends StatelessWidget {
  const SongsList({Key? key, required this.songs}) : super(key: key);
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return SongListItem(song: songs[index]);
      },
    );
  }
}
