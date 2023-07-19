import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class UploadPicturesScreen extends StatefulWidget {
  const UploadPicturesScreen({super.key});

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
    PicturesViewModel.init(context).then((value) {
      setState(() {
        _viewModel = value;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: Center(
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
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Cím"),
                  validator: isValid),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button3D(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _viewModel.uploadPicture(_titleController.text, true);
                  } else {
                    _viewModel.uploadPicture(_titleController.text, false);
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
                    _viewModel.pickImage(image);
                    setState(() {
                      this.image = _viewModel.image!;
                    });
                  }
                },
                child: const Text("Kép kiválasztása"),
              ),
            ],
          )
        ],
      )),
    );
  }
}
