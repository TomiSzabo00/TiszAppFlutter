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
        title: Text('KaraokeBasic'),
      ),
      body: Center(
        child: Text('KaraokeBasic'),
      ),
    );
  }
}