import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/alert_widget.dart';

class UploadPictureScreen extends StatefulWidget {
  const UploadPictureScreen({
    Key? key,
    required this.isAdmin,
    required this.images,
  }) : super(key: key);

  final bool isAdmin;
  final List<File> images;

  @override
  State<UploadPictureScreen> createState() => _UploadPictureScreenState();
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  final PicturesViewModel viewModel = PicturesViewModel();
  final _titleController = TextEditingController();
  PictureCategory? _category;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adatok megadása"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: imagesWithTitleInput()),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kategrória:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: DropdownButtonFormField<PictureCategory>(
                        items: PictureCategory.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.displayName),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Válassz kategóriát...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _category = value;
                          });
                          _formKey.currentState!.validate();
                        },
                        validator: (value) =>
                            value == null ? "Ez kötelező" : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const AlertWidget(
                message:
                    'A feltöltött kép nem kerül egyből a többi kép közé, először át kell essen egy elleőrzésen. Amint ezt valamelyik szervező megtette, a kép látható lesz az alkalmazásban.'),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 20),
                Button3D(
                  width: MediaQuery.of(context).size.width * 0.35,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showLoadingDialog();
                      await viewModel.uploadPicture(
                        widget.images.first,
                        _titleController.text,
                        _category!,
                        widget.isAdmin,
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(); // pop loading dialog
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).popUntil(
                          (route) => route.isFirst); // pop to main menu

                      // show snackbar with success message
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Kép feltöltve!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imagesWithTitleInput() {
    if (widget.images.length == 1) {
      final image = widget.images.first;
      return SizedBox(
        height: 100,
        child: Row(
          children: [
            Image.file(image),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                maxLines: 3,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textAlignVertical: TextAlignVertical.top,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Cím vagy leírás...",
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 220,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.file(image),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                maxLines: 3,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textAlignVertical: TextAlignVertical.top,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Cím vagy leírás...",
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void showLoadingDialog() {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Feltöltés folyamatban...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
