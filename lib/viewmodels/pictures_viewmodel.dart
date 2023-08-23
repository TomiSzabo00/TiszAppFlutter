import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/date_service.dart';
import 'package:tiszapp_flutter/services/notification_service.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

class PicturesViewModel extends ChangeNotifier {
  PicturesViewModel();

  final List<Picture> pictures = [];
  UserData authorDetails = UserData.empty();

  final DatabaseReference picsRef = DatabaseService.database.child("pics");
  final DatabaseReference reviewPicsRef =
      DatabaseService.database.child("reviewPics");
  final DatabaseReference reactionsRef =
      DatabaseService.database.child("reactions");

  TextEditingController commentController = TextEditingController();

  final List<StreamSubscription<DatabaseEvent>> _subscriptions = [];

  void getImages(bool isReview) async {
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
        pictures.sort((a, b) => b.key.compareTo(a.key));
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
          pic.likes =
              pic.likes.orderByKeys(compareTo: (a, b) => b.compareTo(a));
          pictures[picIndex] = pic;
          notifyListeners();
        }
      });

      _subscriptions.add(s1);
      _subscriptions.add(s2);
      _subscriptions.add(s3);
    }
  }

  void disposeListeners() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    _subscriptions.clear();
    pictures.clear();
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
    picsRef.child(picture.key).remove();
    await StorageService.deleteImage(picture.url);
  }

  Future uploadPicture(
      File image, String title, PictureCategory category, bool isAdmin) async {
    final url = await StorageService.uploadImage(image, title);
    if (isAdmin) {
      await _uploadPicToAccepted(
        Picture(
          url: url,
          title: title,
          author: FirebaseAuth.instance.currentUser!.uid,
          category: category,
        ),
      );
    } else {
      await _uploadPicToReview(title, url);
    }
  }

  void loadImageData(Picture pic, bool isReview) async {
    authorDetails = UserData.empty();
    if (isReview) {
      reviewPicsRef.child('${pic.key}/author').once().then((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
      reviewPicsRef.child(pic.key).onChildRemoved.listen((event) {});
    } else {
      picsRef.child('${pic.key}/author').onValue.listen((event) {
        DatabaseService.getUserData(event.snapshot.value.toString())
            .then((value) {
          authorDetails = value;
          notifyListeners();
        });
      });
      picsRef.child(pic.key).onChildRemoved.listen((event) {});
    }

    picsRef.child(pic.key).child('isPicOfTheDay').onValue.listen((event) {
      final isPicOfTheDay = tryCast<bool>(event.snapshot.value) ?? false;
      pic.isPicOfTheDay = isPicOfTheDay;
      notifyListeners();
    });
  }

  bool checkIfAlreadyLiked(Picture pic) {
    if (pic.likes.values.contains(FirebaseAuth.instance.currentUser!.uid)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getLikesOnce(Picture pic) async {
    await picsRef.child(pic.key).child('likes').once().then((event) {
      pic.likes.clear();
      final Map<dynamic, dynamic> value =
          tryCast<Map>(event.snapshot.value) ?? <dynamic, dynamic>{};
      value.forEach((key, value) {
        final valueMap = tryCast<Map>(value);
        if (valueMap != null) {
          pic.likes[valueMap.keys.first] = valueMap.values.first;
        }
      });
      pic.likes = pic.likes.orderByKeys(compareTo: (a, b) => b.compareTo(a));
      notifyListeners();
    });
  }

  Future<String?> _getLatestLikerName(Picture pic) async {
    if (pic.likes.isNotEmpty) {
      final user = await DatabaseService.getUserData(pic.likes.values.first);
      return user.name;
    } else {
      return null;
    }
  }

  Future<String?> getLikeText(Picture pic, Function completion) async {
    await getLikesOnce(pic);
    final lastLikedBy = await _getLatestLikerName(pic);
    completion();
    if (lastLikedBy != null) {
      if (pic.likes.length == 1) {
        return '<b>$lastLikedBy</b> kedveli ezt a képet';
      } else {
        return '<b>$lastLikedBy</b> és még <b>${pic.likes.length - 1} ember</b> kedveli ezt a képet';
      }
    } else {
      return null;
    }
  }

  void toggleReactionTo(Picture picture, Function completion) {
    if (!checkIfAlreadyLiked(picture)) {
      picsRef.child(picture.key).child('likes').push().set({
        DateService.dateInMillisAsString():
            FirebaseAuth.instance.currentUser!.uid
      }).then((value) => completion());
    } else {
      picsRef.child(picture.key).child('likes').once().then((value) {
        final Map<dynamic, dynamic> likes =
            tryCast<Map>(value.snapshot.value) ?? <dynamic, dynamic>{};
        likes.forEach((key, value) {
          final valueMap = tryCast<Map>(value) ?? {};
          if (valueMap.values.first == FirebaseAuth.instance.currentUser!.uid) {
            picsRef
                .child(picture.key)
                .child('likes')
                .child(key)
                .remove()
                .then((value) => completion());
          }
        });
      });
    }
  }

  void likePicture(Picture picture) {
    if (checkIfAlreadyLiked(picture)) {
      return;
    }
    picsRef.child(picture.key).child('likes').push().set({
      DateService.dateInMillisAsString(): FirebaseAuth.instance.currentUser!.uid
    });
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

  String timeStampFromKey(String key) {
    final currDate = DateTime.now();
    final date = DateTime(
      int.parse(key.substring(0, 4)),
      int.parse(key.substring(4, 6)),
      int.parse(key.substring(6, 8)),
      int.parse(key.substring(8, 10)),
      int.parse(key.substring(10, 12)),
      int.parse(key.substring(12, 14)),
      int.parse(key.substring(14, 16)),
    );
    final diff = currDate.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} napja';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} órája';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} perce';
    } else {
      return '${diff.inSeconds} másodperce';
    }
  }

  Future<UserData> getAuthorDetails(String authorId) async {
    return await DatabaseService.getUserData(authorId);
  }

  Future<Map<String, String>> getLikesList(Picture pic) async {
    final Map<String, String> likesList = {};
    await Future.forEach(pic.likes.entries, (entry) async {
      final user = await DatabaseService.getUserData(entry.value);
      likesList[entry.key] = user.name;
    });
    return likesList;
  }

  Future<List<Map<String, String>>> getCommentsList(Picture pic) async {
    final List<Map<String, String>> commentsList = [];
    await Future.forEach(pic.comments, (entry) async {
      final uid = entry.keys.first;
      final user = await DatabaseService.getUserData(uid);
      commentsList.add({user.name: entry.values.first});
    });
    return commentsList;
  }

  void uploadComment(Picture pic) {
    picsRef
        .child(pic.key)
        .child('comments')
        .push()
        .set({FirebaseAuth.instance.currentUser!.uid: commentController.text});
  }

  Future<String?> getCommentCountAsString(Picture pic) async {
    final count = pic.comments.length;
    if (count == 0) {
      return null;
    }
    String article = ' a ';
    if (count == 1 || count == 5 || (count >= 50 && count < 60)) {
      article = ' az ';
    }
    return 'Mind$article$count komment megtekintése';
  }
}

/// Extensions on [Map] of <[K], [V]>
extension ExtendsionsOnMapDynamicDynamic<K, V> on Map<K, V> {
  /// Order by keys
  Map<K, V> orderByKeys({required int Function(K a, K b) compareTo}) {
    return Map.fromEntries(
        entries.toList()..sort((a, b) => compareTo(a.key, b.key)));
  }

  /// Order by values
  Map<K, V> orderByValues({required int Function(V a, V b) compareTo}) {
    return Map.fromEntries(
        entries.toList()..sort((a, b) => compareTo(a.value, b.value)));
  }
}
