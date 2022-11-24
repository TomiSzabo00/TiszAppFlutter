import 'package:flutter/services.dart' show rootBundle;
import 'package:tiszapp_flutter/models/song_data.dart';

class SongsViewModel {
  final List<Song> songs = [];

  Future<void> loadSongs() async {
    final data = await rootBundle.loadString('assets/metadata/names.txt');
    List<String> lines = data.split('\n');
    for (String line in lines) {
      final assetPath = _getAssetPathFromFile(line);
      final currSong = Song(
        name: _getNameFromLine(line),
        lyrics: await rootBundle.loadString(assetPath),
      );
      songs.add(currSong);
    }
  }

  String _getNameFromLine(String line) {
    return line.substring(0, line.length - 4);
  }

  String _getAssetPathFromFile(String file) {
    return 'assets/$file';
  }
}
