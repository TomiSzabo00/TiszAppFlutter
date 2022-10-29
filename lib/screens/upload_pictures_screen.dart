import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

class UploadPicturesScreen extends StatefulWidget {
  const UploadPicturesScreen({super.key});

  @override
  _UploadPicturesScreenState createState() => _UploadPicturesScreenState();
}

class _UploadPicturesScreenState extends State<UploadPicturesScreen> {
  bool isSelected = false;
  XFile? image;
  final _titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            child: isSelected
                ? Image.file(File(image!.path))
                : const Center(
                    child: Text("Nincs kép kiválasztva"),
                  ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: InputField(
                controller: _titleController,
                placeholder: "Cím",
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button3D(
                onPressed: () async {
                  if (image != null) {
                    await StorageService.uploadImage(
                        image!, _titleController.text);
                    // show alert that image is uplodaded
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Kép feltöltve"),
                      ),
                    );
                  } else {
                    // show alert that no image is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nincs kép kiválasztva"),
                      ),
                    );
                  }
                },
                child: const Text("Kép feltöltése"),
              ),
              Button3D(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      this.image = image;
                      isSelected = true;
                    });
                  }
                },
                child: const Text("Kép kiválasztása"),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
