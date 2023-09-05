import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.args}) : super(key: key);

  final ProfileScreenArguments args;

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  final picker = ImagePicker();
  final cropper = ImageCropper();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(widget.args);
    _viewModel.subscribeToProfilePictureChanges();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profilom'),
        ),
        body: Container(
          decoration:
              BoxDecoration(color: isDarkTheme ? Colors.black : Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.45,
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isDarkTheme ? Colors.black : Colors.white
                          ],
                          stops: const [0.4, 0.9],
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.args.user.profilePictureUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Wrap(
                            direction: Axis.vertical,
                            children: [
                              Text(
                                widget.args.user.name,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.args.user.teamNumberAsString,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final croppedFile = await cropper.cropImage(
                                  sourcePath: pickedFile.path,
                                  aspectRatio: const CropAspectRatio(
                                      ratioX: 1, ratioY: 1),
                                  compressQuality: 100,
                                  maxWidth: 700,
                                  maxHeight: 700,
                                  compressFormat: ImageCompressFormat.jpg,
                                );
                                if (croppedFile != null) {
                                  showLoadingDialog();
                                  await _viewModel.uploadProfilePicture(
                                      File(croppedFile.path));
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor:
                                  isDarkTheme ? Colors.white : Colors.black,
                              foregroundColor:
                                  isDarkTheme ? Colors.black : Colors.white,
                            ),
                            child: Icon(
                              MdiIcons.imageEdit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Button3D(
                  width: 160,
                  onPressed: _viewModel.signOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 10),
                      Text(
                        'Kijelentkezés',
                        style: TextStyle(
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    onPressed: () {
                      showAreYouSureDialog(context);
                    },
                    child: const Text(
                      'Fiók végleges törlése',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ));
  }

  void showLoadingDialog() {
    AlertDialog alert = const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Profilkép beállítása..."),
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

  void showAreYouSureDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Biztosan törölni szeretnéd a fiókod?'),
            content: const Text(
                'Ezután nem fogsz tudni többet bejelentkezni a fiókoddal.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Mégse')),
              TextButton(
                  onPressed: () {
                    _viewModel.deleteAccount();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Törlés',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }
}
