import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
import 'package:tiszapp_flutter/models/pics/reaction_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/date_service.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

class PicturesViewModel extends ChangeNotifier {
  PicturesViewModel();

  final List<Picture> pictures = [];

  bool isAdmin = false;
  UserData authorDetails = UserData.empty();
  Map<PicReaction, int> reactions = {
    PicReaction.love: 0,
    PicReaction.funny: 0,
    PicReaction.angry: 0,
    PicReaction.sad: 0,
  };
  PicReaction? currentReaction;

  PicturesViewModel._fromContext(BuildContext context) {
    _context = context;
  }

  static Future<PicturesViewModel> init(BuildContext context) async {
    return PicturesViewModel._fromContext(context);
  }

  late BuildContext? _context;
  final DatabaseReference picsRef =
      FirebaseDatabase.instance.ref().child("debug/pics");
  final DatabaseReference reviewPicsRef =
      FirebaseDatabase.instance.ref().child("debug/reviewPics");
  final DatabaseReference reactionsRef =
      FirebaseDatabase.instance.ref().child("reactions");

  final availableReactions = [
    PicReaction.love,
    PicReaction.funny,
    PicReaction.angry,
    PicReaction.sad,
  ];

  XFile? image;

  void getImages(bool isReview) {
    pictures.clear();
    if (isReview) {
      reviewPicsRef.onChildAdded.listen((event) {
        final snapshot = event.snapshot;
        final Map<dynamic, dynamic> value = tryCast<Map>(snapshot.value) ?? {};
        final pic = Picture.fromSnapshot(snapshot.key ?? 'no key', value);
        pictures.insert(0, pic);
        notifyListeners();
      });

      reviewPicsRef.onChildRemoved.listen((event) {
        final snapshot = event.snapshot;
        final picIndex =
            pictures.indexWhere((element) => element.key == snapshot.key);
        pictures.removeAt(picIndex);
        notifyListeners();
      });
    } else {
      picsRef.onChildAdded.listen((event) {
        final snapshot = event.snapshot;
        final Map<dynamic, dynamic> value = tryCast<Map>(snapshot.value) ?? {};
        final pic = Picture.fromSnapshot(snapshot.key ?? 'no key', value);
        pictures.insert(0, pic);
        notifyListeners();
      });

      picsRef.onChildRemoved.listen((event) {
        final snapshot = event.snapshot;
        final picIndex =
            pictures.indexWhere((element) => element.key == snapshot.key);
        pictures.removeAt(picIndex);
        notifyListeners();
      });
    }
  }

  void _uploadPicToReview(String title, String url) {
    final key = DateService.dateInMillisAsString();
    final pictureData = Picture(
            url: url,
            title: title,
            author: FirebaseAuth.instance.currentUser!.uid)
        .toJson();
    reviewPicsRef.child(key).set(pictureData);
  }

  void _removePicFromReview(Picture picture) async {
    reviewPicsRef.child(picture.key).remove();
  }

  void _uploadPic(Picture picture) {
    final key = DateService.dateInMillisAsString();
    final pictureData = picture.toJson();
    picsRef.child(key).set(pictureData);
  }

  void acceptPic(Picture picture) {
    _removePicFromReview(picture);
    _uploadPic(picture);
  }

  void rejectPic(Picture picture) {
    _removePicFromReview(picture);
  }

  void deletePic(Picture picture) {
    picsRef.child(picture.key).remove();
    StorageService.deleteImage(picture.url);
  }

  void uploadPicture(String title, bool notEmpty) async {
    if (image != null && notEmpty == true) {
      final url = await StorageService.uploadImage(image!, title);
      _uploadPicToReview(title, url);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text("Kép feltöltve"),
        ),
      );
      Navigator.pop(_context!);
    } else if (notEmpty == false) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text("Nem adtál meg címet"),
        ),
      );
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

  void loadImageData(Picture pic, bool isReview) async {
    isAdmin = await _getIsUserAdmin();
    authorDetails = UserData.empty();
    reactions = {
      PicReaction.love: 0,
      PicReaction.funny: 0,
      PicReaction.angry: 0,
      PicReaction.sad: 0,
    };
    currentReaction = null;
    if (isReview) {
      reviewPicsRef.child('${pic.key}/author').once().then((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
    } else {
      picsRef.child('${pic.key}/author').onValue.listen((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
    }

    reactionsRef.onChildAdded.listen((event) {
      final reaction =
          Reaction.fromSnapshot(tryCast<Map>(event.snapshot.value) ?? {});
      RegExp regex = RegExp(r'debug%2F(\d+)\.jpg');
      RegExpMatch? match = regex.firstMatch(pic.url);
      final picKey = match?.group(1) ?? '';
      if (reaction.imageFileName == picKey) {
        reactions[reaction.reaction] = (reactions[reaction.reaction] ?? -1) + 1;
      }
      if (reaction.userId == FirebaseAuth.instance.currentUser!.uid &&
          reaction.imageFileName == picKey) {
        currentReaction = reaction.reaction;
      }
      notifyListeners();
    });

    reactionsRef.onChildRemoved.listen((event) {
      final reaction =
          Reaction.fromSnapshot(tryCast<Map>(event.snapshot.value) ?? {});
      final picKey = pic.key;
      if (reaction.imageFileName == picKey) {
        reactions[reaction.reaction] = (reactions[reaction.reaction] ?? 1) - 1;
      }
      if (reaction.userId == FirebaseAuth.instance.currentUser!.uid &&
          reaction.imageFileName == picKey) {
        currentReaction = null;
      }
      notifyListeners();
    });
  }

  bool isSelected(PicReaction reaction) {
    return currentReaction == reaction;
  }

  void toggleReactionTo(Picture picture, PicReaction reaction) {
    final reactionData = Reaction(
      userId: FirebaseAuth.instance.currentUser!.uid,
      imageFileName: picture.key,
      reaction: reaction,
    );

    if (currentReaction == null) {
      reactionsRef
          .child(DateService.dateInMillisAsString())
          .set(reactionData.toJson());
    } else if (currentReaction == reaction) {
      reactionsRef.once().then((value) {
        final Map<dynamic, dynamic> values =
            tryCast<Map>(value.snapshot.value) ?? {};
        values.forEach((key, value) {
          final reaction = Reaction.fromSnapshot(tryCast<Map>(value) ?? {});
          final imageKey = picture.key;
          if (reaction.userId == FirebaseAuth.instance.currentUser!.uid &&
              reaction.imageFileName == imageKey) {
            reactionsRef.child(key).remove();
          }
        });
      });
    } else {
      reactionsRef.once().then((value) {
        final Map<dynamic, dynamic> values =
            tryCast<Map>(value.snapshot.value) ?? {};
        values.forEach((key, value) {
          final reaction = Reaction.fromSnapshot(tryCast<Map>(value) ?? {});
          final imageKey = picture.key;
          if (reaction.userId == FirebaseAuth.instance.currentUser!.uid &&
              reaction.imageFileName == imageKey) {
            reactionsRef.child(key).remove();
          }
        });
        reactionsRef
            .child(DateService.dateInMillisAsString())
            .set(reactionData.toJson());
      });
    }
  }
}
