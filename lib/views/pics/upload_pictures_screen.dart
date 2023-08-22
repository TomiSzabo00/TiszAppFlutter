import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class UploadPicturesScreen extends StatefulWidget {
  const UploadPicturesScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  State<UploadPicturesScreen> createState() => _UploadPicturesScreenState();
}

class _UploadPicturesScreenState extends State<UploadPicturesScreen> {
  PicturesViewModel _viewModel = PicturesViewModel();
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
