import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/song_data.dart';
import 'package:tiszapp_flutter/screens/songs_detail_screen.dart';
import 'package:tiszapp_flutter/widgets/song_list_item.dart';
import 'package:tiszapp_flutter/widgets/songs_list.dart';
import 'package:tiszapp_flutter/widgets/songs_summary_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen>
    with TickerProviderStateMixin {
  final List<Song> _songs = [];
  late final Future _futureSongs;

  Future<void> loadSongs() async {
    final data = await rootBundle.loadString('assets/metadata/names.txt');
    List<String> lines = data.split('\n');
    for (String line in lines) {
      final assetPath = _getAssetPathFromFile(line);
      final currSong = Song(
        name: _getNameFromLine(line),
        lyrics: await rootBundle.loadString(assetPath),
      );
      _songs.add(currSong);
    }
  }

  String _getNameFromLine(String line) {
    return line.substring(0, line.length - 4);
  }

  String _getAssetPathFromFile(String file) {
    return 'assets/$file';
  }

  @override
  void initState() {
    super.initState();
    _futureSongs = loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder(
      future: _futureSongs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            //extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Songs'),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isDarkTheme
                      ? const AssetImage("images/bg2_night.png")
                      : const AssetImage("images/bg2_day.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: TabBarView(
                controller:
                    TabController(length: _songs.length + 1, vsync: this),
                children: [
                  SongsSummaryScreen(songs: _songs),
                  for (Song song in _songs)
                    SongsDetailScreen(
                      song: song,
                      tab: true,
                    ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
