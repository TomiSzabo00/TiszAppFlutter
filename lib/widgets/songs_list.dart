import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'package:tiszapp_flutter/widgets/song_list_item.dart';

class SongsList extends StatelessWidget {
  const SongsList({Key? key, required this.songs}) : super(key: key);
  final Set<Song> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return SongListItem(song: songs.elementAt(index));
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 1,
        );
      },
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }
}
