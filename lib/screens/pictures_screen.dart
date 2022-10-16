import 'package:flutter/material.dart';

class PicturesScreen extends StatelessWidget {
  const PicturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek"),
      ),
      body: const Center(
        child: Text("Képek"),
      ),
    );
  }
}
