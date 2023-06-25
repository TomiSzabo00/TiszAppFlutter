import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tiszapp_flutter/models/song_data.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

class SongsViewModel with ChangeNotifier {
  final List<Song> songs = [];
  final List<Song> filteredSongs = [];
  bool isLoading = true;

  SongsViewModel();

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
    final onlineSongs = await StorageService.getSongs();
    songs.addAll(onlineSongs);
    filteredSongs.addAll(songs);
    isLoading = false;
    notifyListeners();
  }

  String _getNameFromLine(String line) {
    return line.substring(0, line.length - 4);
  }

  String _getAssetPathFromFile(String file) {
    return 'assets/songs/$file';
  }

  void filterSongs(String filter) {
    filteredSongs.clear();
    if (filter.isEmpty) {
      filteredSongs.addAll(songs);
    } else {
      for (Song song in songs) {
        if (song.name.toLowerCase().contains(filter.toLowerCase()) ||
            song.lyrics.toLowerCase().contains(filter.toLowerCase())) {
          filteredSongs.add(song);
        }
      }
    }
    notifyListeners();
  }
}
