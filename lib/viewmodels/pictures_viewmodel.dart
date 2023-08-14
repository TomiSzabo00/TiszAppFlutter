import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
import 'package:tiszapp_flutter/models/pics/reaction_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/date_service.dart';
import 'package:tiszapp_flutter/services/notification_service.dart';
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
      DatabaseService.database.child("pics");
  final DatabaseReference reviewPicsRef =
      DatabaseService.database.child("reviewPics");
  final DatabaseReference reactionsRef =
      DatabaseService.database.child("reactions");

  final availableReactions = [
    PicReaction.love,
    PicReaction.funny,
    PicReaction.angry,
    PicReaction.sad,
  ];

  XFile? image;
  bool isValidImage = true;

  final List<StreamSubscription<DatabaseEvent>> _subscriptions = [];
  BuildContext? context;

  void getImages(bool isReview) {
    for (var element in _subscriptions) {
      element.cancel();
    }
    _subscriptions.clear();
    pictures.clear();
    if (isReview) {
      var s1 = reviewPicsRef.onChildAdded.listen((event) {
        final snapshot = event.snapshot;
        final Map<dynamic, dynamic> value = tryCast<Map>(snapshot.value) ?? {};
        final pic = Picture.fromSnapshot(snapshot.key ?? 'no key', value);
        pictures.insert(0, pic);
        notifyListeners();
      });

      var s2 = reviewPicsRef.onChildRemoved.listen((event) {
        final snapshot = event.snapshot;
        final picIndex =
            pictures.indexWhere((element) => element.key == snapshot.key);
        if (picIndex != -1) {
          pictures.removeAt(picIndex);
          notifyListeners();
        }
      });
      _subscriptions.add(s1);
      _subscriptions.add(s2);
    } else {
      var s1 = picsRef.onChildAdded.listen((event) {
        final snapshot = event.snapshot;
        final Map<dynamic, dynamic> value = tryCast<Map>(snapshot.value) ?? {};
        final pic = Picture.fromSnapshot(snapshot.key ?? 'no key', value);
        pictures.insert(0, pic);
        notifyListeners();
      });

      var s2 = picsRef.onChildRemoved.listen((event) {
        final snapshot = event.snapshot;
        final picIndex =
            pictures.indexWhere((element) => element.key == snapshot.key);
        if (picIndex != -1) {
          pictures.removeAt(picIndex);
          notifyListeners();
        }
      });

      var s3 = picsRef.onChildChanged.listen((event) {
        final snapshot = event.snapshot;
        final Map<dynamic, dynamic> value = tryCast<Map>(snapshot.value) ?? {};
        final pic = Picture.fromSnapshot(snapshot.key ?? 'no key', value);
        final picIndex =
            pictures.indexWhere((element) => element.key == snapshot.key);
        if (picIndex != -1 && picIndex < pictures.length) {
          pictures[picIndex] = pic;
          notifyListeners();
        }
      });

      _subscriptions.add(s1);
      _subscriptions.add(s2);
      _subscriptions.add(s3);
    }
  }

  Future<void> _uploadPicToReview(String title, String url) async {
    final key = DateService.dateInMillisAsString();
    final pictureData = Picture(
            url: url,
            title: title,
            author: FirebaseAuth.instance.currentUser!.uid)
        .toJson();
    await reviewPicsRef.child(key).set(pictureData);
  }

  Future<void> _removePicFromReview(Picture picture) async {
    await reviewPicsRef.child(picture.key).remove();
  }

  Future<void> _uploadPicToAccepted(Picture picture) async {
    final key = DateService.dateInMillisAsString();
    final pictureData = picture.toJson();
    await picsRef.child(key).set(pictureData);
  }

  Future<void> acceptPic(Picture picture) async {
    await _removePicFromReview(picture);
    await _uploadPicToAccepted(picture);
  }

  Future<void> rejectPic(Picture picture) async {
    await _removePicFromReview(picture);
    await StorageService.deleteImage(picture.url);
  }

  Future<void> deletePic(Picture picture) async {
    context = null;
    picsRef.child(picture.key).remove();
    await StorageService.deleteImage(picture.url);
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

  Stream<CachedNetworkImageProvider> getImageProvider(Picture pic) {
    isValidImage = true;
    final controller = StreamController<CachedNetworkImageProvider>();
    final provider = CachedNetworkImageProvider(
      pic.url,
      errorListener: () {
        isValidImage = false;
        notifyListeners();
      },
    );
    provider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) {
              controller.add(provider);
            },
            onError: (exception, stackTrace) {
              isValidImage = false;
              notifyListeners();
            },
          ),
        );
    return controller.stream;
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
    context = null;
    currentReaction = null;
    if (isReview) {
      reviewPicsRef.child('${pic.key}/author').once().then((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
      reviewPicsRef.child(pic.key).onChildRemoved.listen((event) {
        if (context != null) {
          Navigator.pop(context!);
          context = null;
        }
      });
    } else {
      picsRef.child('${pic.key}/author').onValue.listen((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
      picsRef.child(pic.key).onChildRemoved.listen((event) {
        if (context != null) {
          Navigator.pop(context!);
          context = null;
        }
      });
    }

    reactionsRef.onValue.listen((event) {
      reactions = {
        PicReaction.love: 0,
        PicReaction.funny: 0,
        PicReaction.angry: 0,
        PicReaction.sad: 0,
      };
      currentReaction = null;
      final Map<dynamic, dynamic> values =
          tryCast<Map>(event.snapshot.value) ?? {};
      values.forEach((key, value) {
        final reaction = Reaction.fromSnapshot(tryCast<Map>(value) ?? {});
        if (reaction.imageFileName == pic.key) {
          reactions[reaction.reaction] = reactions[reaction.reaction]! + 1;
          if (reaction.userId == FirebaseAuth.instance.currentUser!.uid) {
            currentReaction = reaction.reaction;
          }
        }
      });
      notifyListeners();
    });

    picsRef.child(pic.key).child('isPicOfTheDay').onValue.listen((event) {
      final isPicOfTheDay = tryCast<bool>(event.snapshot.value) ?? false;
      pic.isPicOfTheDay = isPicOfTheDay;
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

  void choosePic(Picture picture) {
    picsRef.child(picture.key).child('isPicOfTheDay').set(true);
    NotificationService.getTokensAsMap().then((tokens) {
      final token = tokens.keys.firstWhere(
          (element) => tokens[element] == picture.author,
          orElse: () => '');
      if (token.isNotEmpty) {
        NotificationService.sendNotification(
          [token],
          'Gratulálunk!',
          'A te képed lett a mai nap képe!',
        ).then((response) {
          if (kDebugMode) {
            debugPrint('PicOfTheDay notification sent: $response');
          }
        });
      }
    });
  }
}
