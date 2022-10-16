import 'package:flutter/material.dart';

class ScoresScreen extends StatelessWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pontállás"),
      ),
      body: const Center(
        child: Text("Pontállás"),
      ),
    );
  }
}
