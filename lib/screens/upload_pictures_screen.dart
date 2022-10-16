import 'package:flutter/material.dart';

class UploadPicturesScreen extends StatelessWidget {
  const UploadPicturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: const Center(
        child: Text("Képek feltöltése"),
      ),
    );
  }
}
