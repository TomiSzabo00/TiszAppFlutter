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
import 'package:tiszapp_flutter/widgets/picture_item.dart';

class PicturesViewModel extends ChangeNotifier {
  PicturesViewModel();

  bool isAdmin = false;
  UserData authorDetails = UserData.empty();
  Map<PicReaction, int> reactions = {
    PicReaction.love: 0,
    PicReaction.funny: 0,
    PicReaction.angry: 0,
    PicReaction.sad: 0,
  };
  PicReaction? currentReaction;

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
  final DatabaseReference reactionsRef =
      FirebaseDatabase.instance.ref().child("reactions");

  final availableReactions = [
    PicReaction.love,
    PicReaction.funny,
    PicReaction.angry,
    PicReaction.sad,
  ];

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
    authorDetails = UserData.empty();
    reactions = {
      PicReaction.love: 0,
      PicReaction.funny: 0,
      PicReaction.angry: 0,
      PicReaction.sad: 0,
    };
    currentReaction = null;
    picsRef.child('${pic.key}/author').onValue.listen((event) {
      DatabaseService.getUserData(event.snapshot.value.toString())
          .then((value) {
        authorDetails = value;
        notifyListeners();
      });
    });

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
      reactionsRef.child(DateService.dateInMillisAsString()).set(reactionData.toJson());
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
        reactionsRef.child(DateService.dateInMillisAsString()).set(reactionData.toJson());
      });
    }
  }
}
