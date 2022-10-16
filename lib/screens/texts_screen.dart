import 'package:flutter/material.dart';

class TextsScreen extends StatelessWidget {
  const TextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szövegek"),
      ),
      body: const Center(
        child: Text("Szövegek"),
      ),
    );
  }
}
