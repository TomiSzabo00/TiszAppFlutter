import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/song_data.dart';
import 'package:tiszapp_flutter/widgets/songs_list.dart';

class SongsSummaryScreen extends StatefulWidget {
  const SongsSummaryScreen({Key? key, required this.songs}) : super(key: key);
  final List<Song> songs;

  @override
  SongsSummaryScreenState createState() => SongsSummaryScreenState();
}

class SongsSummaryScreenState extends State<SongsSummaryScreen> {
  var _songs = <Song>[];

  void setSongsBySearch(String search) {
    setState(() {
      _songs = widget.songs.toList();
    });
    if (search.isNotEmpty) {
      setState(() {
        _songs.retainWhere((element) =>
            element.name.toLowerCase().contains(search.toLowerCase()) ||
            element.lyrics.toLowerCase().contains(search.toLowerCase()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _songs = widget.songs.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setSongsBySearch(value);
            },
            decoration: const InputDecoration(
              hintText: 'Keresés dalszöveg vagy cím alapján',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
            ),
          ),
        ),
        Expanded(
          child: SongsList(songs: _songs),
        ),
      ],
    );
  }
}
