import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/tinder_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/viewmodels/tinder_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/alert_widget.dart';
import 'package:tiszapp_flutter/widgets/tinder_tile.dart';

class TinderRegistrationScreen extends StatefulWidget {
  const TinderRegistrationScreen({Key? key, required this.user})
      : super(key: key);

  final UserData user;

  @override
  TinderRegistrationScreenState createState() =>
      TinderRegistrationScreenState();
}

class TinderRegistrationScreenState extends State<TinderRegistrationScreen> {
  final picker = ImagePicker();
  final cropper = ImageCropper();
  late OverlayEntry _overlayEntry;
  final viewModel = TinderViewModel();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regisztráció'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                'Ez a funkció a HázasPárbajra segít párt találni. Ha nincs senki a közvetlen környezetedben, aki indulna veled, itt regisztrálhatsz, és a hasonló helyzetű emberek között kereshetsz párt magadnak.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const AlertWidget(
                message:
                    'Kérünk, hogy tényleg csak akkor regisztrálj, ha komolyan gondolod, hogy részt veszel a HázasPárbajban, és még nincs párod.'),
            const SizedBox(height: 20),
            Button3D(
              onPressed: () {
                showPicDialog();
              },
              child: Text(
                'Regisztráció',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPicDialog() {
    showDialog(
      context: context,
      builder: (context) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return AlertDialog(
          title: const Text('Kép készítése'),
          content: const Text(
              'Hogy a többiek felismerhessenek, kérjük, készíts most egy képet magadról, amivel regisztrálsz.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Mégsem'),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    requestFullMetadata: false,
                    preferredCameraDevice: CameraDevice.front);
                if (pickedFile != null) {
                  final croppedFile = await cropper.cropImage(
                    sourcePath: pickedFile.path,
                    aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
                    compressQuality: 100,
                    maxWidth: 700,
                    maxHeight: 700,
                    compressFormat: ImageCompressFormat.jpg,
                  );
                  if (croppedFile != null) {
                    showPreviewOverlay(image: File(croppedFile.path));
                  }
                }
              },
              child: const Text('Rendben'),
            ),
          ],
        );
      },
    );
  }

  void showPreviewOverlay({required File image}) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Itt láthatod, hogy fogsz megjelenni a többieknek:'),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8 * 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TinderTile(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8 * 4 / 3,
                        data: TinderData(
                          name: widget.user.name,
                          teamNum: widget.user.teamNum,
                        ),
                        localImage: Image.file(image),
                      ),
                    )),
                const Text('Ha elégedett vagy, regisztrálhatsz.'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _overlayEntry.remove();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red,
                      ),
                      child: const Icon(Icons.close),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _overlayEntry.remove();
                        setState(() {
                          isLoading = true;
                        });
                        await viewModel.register(user: widget.user, image: image);
                        setState(() {
                          Navigator.of(context).pop();
                          isLoading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.green[100],
                        foregroundColor: Colors.green,
                      ),
                      child: const Icon(Icons.check),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(
      _overlayEntry,
    );
  }
}
