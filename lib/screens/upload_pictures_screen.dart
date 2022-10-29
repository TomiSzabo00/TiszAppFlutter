import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class UploadPicturesScreen extends StatelessWidget {
  const UploadPicturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: Center(
        child: Button3D(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              await StorageService.uploadImage(image);
              // show alert that image is uplodaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AlertDialog(
                  title: const Text("Siker"),
                  content: const Text("A kép feltöltése sikerült!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              });
            }
          },
          child: const Text("Kép kiválasztása"),
        ),
      ),
    );
  }
}
