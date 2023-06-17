import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/songs_viewmodel.dart';
import 'package:tiszapp_flutter/views/songs_detail_screen.dart';
import 'package:tiszapp_flutter/views/songs_summary_screen.dart';

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
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.dstATop),
                ),
              ),
              child: SongsSummaryScreen(songs: _viewModel.songs),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isDarkTheme
                    ? const AssetImage("images/bg2_night.png")
                    : const AssetImage("images/bg2_day.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.dstATop),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
