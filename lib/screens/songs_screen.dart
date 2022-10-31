import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  Future<String> loadSongs() async {
    final data = await rootBundle.loadString('assets/metadata/names.txt');
    List<String> lines = data.split('\n');
    List<String> songs = [];
    for (String line in lines) {
      songs.add('assets/$line');
    }

    return await rootBundle.loadString(songs[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dalok"),
      ),
      body: FutureBuilder(
        future: loadSongs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
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
