import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

class UploadPicturesScreen extends StatefulWidget {
  const UploadPicturesScreen({super.key, required this.context});
  final BuildContext context;

  @override
  State<UploadPicturesScreen> createState() => _UploadPicturesScreenState();
}

class _UploadPicturesScreenState extends State<UploadPicturesScreen> {
  PicturesViewModel _viewModel = PicturesViewModel();
  final _titleController = TextEditingController();
  XFile? image;

  @override
  void initState() {
    super.initState();
    PicturesViewModel.init(widget.context).then((value) {
      setState(() {
        _viewModel = value;
      });
    });
  }

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
              child: InputField(
                controller: _titleController,
                placeholder: "Cím",
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button3D(
                onPressed: () async {
                  _viewModel.uploadPicture(_titleController.text);
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
          ),
        ],
      )),
    );
  }
}
