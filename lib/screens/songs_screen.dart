import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tiszapp_flutter/data/song_data.dart';
import 'package:tiszapp_flutter/widgets/song_list_item.dart';
import 'package:tiszapp_flutter/widgets/songs_list.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen> {
  List<Song> _songs = [];
  final List<Song> _songsCopy = [];
  late final Future _futureSongs;

  Future<void> loadSongs() async {
    final data = await rootBundle.loadString('assets/metadata/names.txt');
    List<String> lines = data.split('\n');
    for (String line in lines) {
      final assetPath = _getAssetPathFromFile(line);
      final currSong = Song(
        name: line,
        lyrics: await rootBundle.loadString(assetPath),
        assetPath: assetPath,
      );
      _songs.add(currSong);
      _songsCopy.add(currSong);
    }
    //return await rootBundle.loadString(songs[0]);
  }

  String _getTitleFromFile(String file) {
    //remove .txt from string
    return file.substring(0, file.length - 4);
  }

  String _getAssetPathFromFile(String file) {
    return 'assets/$file';
  }

  void setSongsBySearch(String search) {
    setState(() {
      _songs = _songsCopy.toList();
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
    _futureSongs = loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
      ),
      body: FutureBuilder(
        future: _futureSongs,
        builder: (context, snapshot) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setSongsBySearch(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
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
        },
      ),
    );
  }
}
