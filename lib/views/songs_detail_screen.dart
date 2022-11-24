import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/song_data.dart';

class SongsDetailScreen extends StatelessWidget {
  const SongsDetailScreen({Key? key, required this.song, this.tab = false})
      : super(key: key);
  final Song song;
  final bool tab;
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: !tab
          ? AppBar(
              title: const Text('Daloskönyv'),
            )
          : null,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: isDarkTheme
                ? const AssetImage("images/bg2_night.png")
                : const AssetImage("images/bg2_day.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  song.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(song.lyrics, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
