import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';

import '../models/pics/picture_data.dart';

class PicturesViewModel extends ChangeNotifier {
  PicturesViewModel();

  bool isAdmin = false;
  UserData authorDetails = UserData.empty();

  PicturesViewModel._fromContext(BuildContext context, bool isAdmin) {
    _context = context;
    isAdmin = isAdmin;
  }

  static Future<PicturesViewModel> init(BuildContext context) async {
    return PicturesViewModel._fromContext(
        context, await PicturesViewModel._getIsUserAdmin());
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
      children.add(PictureItem(pic: pic, isReview: isReview, isAdmin: isAdmin));
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

  static Future<bool> _getIsUserAdmin() async {
    return (await DatabaseService.getUserData(
            FirebaseAuth.instance.currentUser!.uid))
        .isAdmin;
  }

  void loadImageData(Picture pic) {
    picsRef.child('${pic.key}/author').onValue.listen((event) {
      DatabaseService.getUserData(event.snapshot.value.toString()).then((value) {
        authorDetails = value;
        notifyListeners();
      });
    });

    picsRef.child(pic.key).onChildChanged.listen((event) {
      if (event.snapshot.key == "reactions") {
        (tryCast<Map>(event.snapshot.value) ?? {}).forEach((key, value) {
          pic.reactions[key.toString().toPicReaction] =
              (tryCast<List>(value) ?? []).map((e) => e.toString()).toList();
        });
        notifyListeners();
      }
    });
  }

  bool isSelected(Picture picture, PicReaction reaction) {
    final reactions = picture.reactions[reaction] ?? [];
    return reactions.contains(FirebaseAuth.instance.currentUser!.uid);
  }

  void toggleReactionTo(Picture picture, PicReaction reaction) {
    final reactions = picture.reactions[reaction] ?? [];
    if (reactions.contains(FirebaseAuth.instance.currentUser!.uid)) {
      reactions.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      final existingReactionKey = picture.reactions.keys.firstWhere(
          (element) => picture.reactions[element]!
              .contains(FirebaseAuth.instance.currentUser!.uid),
          orElse: () => reaction);
      if (existingReactionKey != reaction) {
        picture.reactions[existingReactionKey]!
            .remove(FirebaseAuth.instance.currentUser!.uid);
      }
      reactions.add(FirebaseAuth.instance.currentUser!.uid);
    }
    picture.reactions[reaction] = reactions;
    picsRef.child(picture.key).update(picture.toJson());
    notifyListeners();
  }
}
