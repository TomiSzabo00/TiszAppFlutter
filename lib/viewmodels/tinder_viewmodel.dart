import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/tinder/tinder_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

class TinderViewModel extends ChangeNotifier {
  final List<String> liked = [];
  final List<String> disliked = [];

  Future<List<TinderData>> getCards() async {
    List<TinderData> allCards = [];
    await DatabaseService.database.child('tinder').once().then((event) async {
      final datas = tryCast<Map>(event.snapshot.value);
      if (datas == null) {
        return [];
      }
      for (final data in datas.entries) {
        final tinderData = TinderData.fromJson(data.key, data.value);
        if (tinderData.uid != FirebaseAuth.instance.currentUser!.uid &&
            !liked.contains(tinderData.uid) &&
            !disliked.contains(tinderData.uid)) {
          allCards.add(tinderData);
        }
      }
    });

    return allCards;
  }

  void subscribeToLikes() {
    liked.clear();
    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('likes')
        .onChildAdded
        .listen((event) {
      final data = tryCast<String>(event.snapshot.value);
      if (data == null) {
        return;
      }
      liked.add(data);
      notifyListeners();
    });

    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('likes')
        .onChildRemoved
        .listen((event) {
      final data = tryCast<String>(event.snapshot.value);
      if (data == null) {
        return;
      }
      liked.remove(data);
      notifyListeners();
    });
  }

  void subscribeToDislikes() {
    disliked.clear();
    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('dislikes')
        .onChildAdded
        .listen((event) {
      final data = tryCast<String>(event.snapshot.value);
      if (data == null) {
        return;
      }
      disliked.add(data);
      notifyListeners();
    });

    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('dislikes')
        .onChildRemoved
        .listen((event) {
      final data = tryCast<String>(event.snapshot.value);
      if (data == null) {
        return;
      }
      disliked.remove(data);
      notifyListeners();
    });
  }

  Stream<bool> isUserRegistered() {
    return DatabaseService.database.child('tinder').onValue.map((event) {
      final data = tryCast<Map>(event.snapshot.value);
      if (data == null) {
        return false;
      }
      return data.keys.contains(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  Future register({required UserData user, required File image}) async {
    final imageUrl =
        await StorageService.uploadPic(file: image, path: 'tinder_images');
    final data = TinderData(
        uid: user.uid,
        name: user.name,
        teamNum: user.teamNum,
        imageUrl: imageUrl);
    await DatabaseService.database
        .child('tinder')
        .child(user.uid)
        .set(data.toJson());
  }

  void addSample() async {
    final users = await FirebaseDatabase.instance.ref().child('users').once();
    final usersData = users.snapshot;
    final usersList =
        usersData.children.map((e) => UserData.fromSnapshot(e)).toList();
    for (final user in usersList) {
      const imageUrl = UserData.defaultUrl;
      final data = TinderData(
          uid: user.uid,
          name: user.name,
          teamNum: user.teamNum,
          imageUrl: imageUrl);
      if (user.uid == FirebaseAuth.instance.currentUser!.uid) {
        continue;
      }
      await DatabaseService.database
          .child('tinder')
          .child(user.uid)
          .set(data.toJson());
    }
  }

  void like({required TinderData data}) {
    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('likes')
        .push()
        .set(data.uid);
    notifyListeners();
  }

  void dislike({required TinderData data}) {
    DatabaseService.database
        .child('tinder')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('dislikes')
        .push()
        .set(data.uid);
    notifyListeners();
  }
}
