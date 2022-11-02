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
  final List<Song> _songs = [];

  Future<void> loadSongs() async {
    final data = await rootBundle.loadString('assets/metadata/names.txt');
    List<String> lines = data.split('\n');
    for (String line in lines) {
      final assetPath = _getAssetPathFromFile(line);
      _songs.add(Song(
          name: _getTitleFromFile(line),
          lyrics: await rootBundle.loadString(assetPath),
          assetPath: assetPath));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
      ),
      body: FutureBuilder(
        future: loadSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SongsList(songs: _songs);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
