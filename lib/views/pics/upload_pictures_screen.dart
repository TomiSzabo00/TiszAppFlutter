import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

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
  XFile? image;
  bool notEmpty = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      _viewModel = PicturesViewModel();
    });
  }

  String? isValid(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else {
      return null;
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: image != null
                ? Image.file(File(image!.path))
                : const Center(
                    child: Text("Nincs kép kiválasztva"),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: TextFormField(
                  controller: _titleController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kép címe',
                  ),
                  validator: isValid),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button3D(
                onPressed: () async {
                  _viewModel.uploadPicture(_titleController.text, widget.isAdmin);
                },
                child: Text(
                  "Kép feltöltése",
                  style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Button3D(
                width: 140,
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    _viewModel.pickImage(image);
                    setState(() {
                      this.image = _viewModel.image!;
                    });
                  }
                },
                child: Text(
                  "Kép kiválasztása",
                  style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}
