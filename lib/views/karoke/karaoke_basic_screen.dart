import 'package:flutter/material.dart';

class KaraokeBasicScreen extends StatefulWidget {
  @override
  KaraokeBasicScreenState createState() => KaraokeBasicScreenState();
}

class KaraokeBasicScreenState extends State<KaraokeBasicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karaoke'),
      ),
      body: Column(
        children: [
          const Text('Karaoke'),
        ],
      ),
    );
  }
}