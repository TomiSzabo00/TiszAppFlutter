import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class UploadPictureScreen extends StatefulWidget {
  const UploadPictureScreen({
    Key? key,
    required this.isAdmin,
    required this.image,
  }) : super(key: key);

  final bool isAdmin;
  final File image;

  @override
  State<UploadPictureScreen> createState() => _UploadPictureScreenState();
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  final _titleController = TextEditingController();
  PictureCategory? _category;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adatok megadása"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  Image.file(widget.image),
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
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          Row(
            children: [
              const SizedBox(width: 20),
              Button3D(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text("Kép feltöltése"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
