import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/karaoke/karaoke_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/date_service.dart';

class KaraokeBasicViewModel extends ChangeNotifier {
  final List<KaraokeData> signedUpUsers = [];
  final database = DatabaseService.database;
  final musicController = TextEditingController();

  void subscribeToUserChanges() async {
    database.child('karaoke/signed_up').onChildAdded.listen((event) {
      KaraokeData.fromSnapshot(event.snapshot).then((value) => {
            if (!signedUpUsers.any((element) =>
                (element.user.uid == value.user.uid &&
                    element.music == value.music)))
              signedUpUsers.add(value),
            notifyListeners(),
          });
    });

    database.child('karaoke/signed_up').onChildRemoved.listen((event) {
      KaraokeData.fromSnapshot(event.snapshot).then((value) {
        final index = signedUpUsers.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.music == value.music));
        if (index != -1) {
          signedUpUsers.removeAt(index);
        }
        notifyListeners();
      });
    });

    database.child('karaoke/signed_up').onChildChanged.listen((event) {
      KaraokeData.fromSnapshot(event.snapshot).then((value) {
        final index = signedUpUsers.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.music == value.music));
        if (index != -1) {
          signedUpUsers[index] = value;
        }
        notifyListeners();
      });
    });
  }

  Future<bool> signUpForKaraoke() async {
    final key = DateService.dateInMillisAsString();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await DatabaseService.getUserData(uid);
    final data =
        KaraokeData(user: userData, music: musicController.text).toJson();
    final index = signedUpUsers.indexWhere((element) =>
        (element.user.uid == userData.uid &&
            element.music == musicController.text));
    if (index != -1) {
      notifyListeners();
      return true;
    }
    database.child('karaoke/signed_up/$key').set(data);
    musicController.clear();
    return false;
  }

  void removeFromKaraoke(KaraokeData data) {
    database.child('karaoke/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        KaraokeData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid && value.music == data.music)
                database.child('karaoke/signed_up/${e.key}').remove()
            });
      }
    });
  }

  void markAsPlayed(KaraokeData data) {
    database.child('karaoke/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        KaraokeData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid && value.music == data.music)
                database.child('karaoke/signed_up/${e.key}/didPlay').set(true)
            });
      }
    });
  }

  void markAsNotPlayed(KaraokeData data) {
    database.child('karaoke/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        KaraokeData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid && value.music == data.music)
                database.child('karaoke/signed_up/${e.key}/didPlay').set(false)
            });
      }
    });
  }
}
