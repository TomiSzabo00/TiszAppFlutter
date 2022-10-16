import 'package:flutter/material.dart';

class UploadScoreScreen extends StatelessWidget {
  const UploadScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pontok feltöltése"),
      ),
      body: const Center(
        child: Text("Pontok feltöltése"),
      ),
    );
  }
}
