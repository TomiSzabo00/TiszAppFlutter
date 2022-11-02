import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/song_data.dart';

class SongsDetailScreen extends StatelessWidget {
  const SongsDetailScreen({Key? key, required this.song}) : super(key: key);
  final Song song;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daloskönyv'),
      ),
      body: SingleChildScrollView(
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
    );
  }
}
