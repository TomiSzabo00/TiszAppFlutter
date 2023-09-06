import 'package:flutter/material.dart';

class TinderScreen extends StatefulWidget {
  const TinderScreen({super.key});

  @override
  TinderScreenState createState() => TinderScreenState();
}

class TinderScreenState extends State<TinderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinder'),
      ),
      body: const Center(
        child: Text('Tinder Screen'),
      ),
    );
  }
}