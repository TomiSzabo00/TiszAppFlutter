import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';

import '../models/pics/picture_data.dart';

class PicturesViewModel {
  PicturesViewModel();

  PicturesViewModel._fromContext(BuildContext context) {
    _context = context;
  }

  static Future<PicturesViewModel> init(BuildContext context) async {
    return PicturesViewModel._fromContext(context);
  }

  late BuildContext? _context;
  final DatabaseReference picsRef =
      FirebaseDatabase.instance.ref().child("debug/pics");

  XFile? image;

  List<Widget> handlePics(AsyncSnapshot snapshot, bool isReview) {
    final Map<dynamic, dynamic> values =
        snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
    final List<Widget> children = [];
    final List<Picture> pics = [];
    values.forEach((key, value) {
      final pic = Picture.fromSnapshot(key, value);
      pics.add(pic);
    });
    pics.sort((a, b) => b.key.compareTo(a.key));
    for (var pic in pics) {
      children.add(PictureItem(pic: pic, isReview: isReview));
    }
    return children;
  }

  void uploadPicture(String title) async {
    if (image != null) {
      await StorageService.uploadImage(image!, title);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text("Kép feltöltve"),
        ),
      );
      Navigator.pop(_context!);
    } else {
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text("Nincs kép kiválasztva"),
        ),
      );
    }
  }

  void pickImage(XFile image) {
    this.image = image;
  }

  void loadIamgeData() {

  }
}
