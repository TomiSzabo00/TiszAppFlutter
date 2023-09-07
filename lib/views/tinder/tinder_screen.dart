import 'package:flutter/material.dart';

class TinderScreen extends StatefulWidget {
  const TinderScreen({super.key, required this.context});

  final BuildContext context;

  @override
  TinderScreenState createState() => TinderScreenState();
}

class TinderScreenState extends State<TinderScreen> {
  @override
  Widget build(BuildContext context) {
    context = widget.context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Párkereső'),
      ),
      body: const Center(
        child: Text('Keress párt!'),
      ),
    );
  }
}
