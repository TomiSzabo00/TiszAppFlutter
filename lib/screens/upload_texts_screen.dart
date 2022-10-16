import 'package:flutter/material.dart';

class UploadTextsScreen extends StatelessWidget {
  const UploadTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szövegek feltöltése"),
      ),
      body: const Center(
        child: Text("Szövegek feltöltése"),
      ),
    );
  }
}
