import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'package:tiszapp_flutter/viewmodels/songs_viewmodel.dart';
import 'package:tiszapp_flutter/views/songs_detail_screen.dart';
import 'package:tiszapp_flutter/widgets/songs_summary_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen>
    with TickerProviderStateMixin {
  final SongsViewModel _viewModel = SongsViewModel();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder(
      future: _viewModel.loadSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
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
                controller: TabController(
                    length: _viewModel.songs.length + 1, vsync: this),
                children: [
                  SongsSummaryScreen(songs: _viewModel.songs),
                  for (Song song in _viewModel.songs)
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
