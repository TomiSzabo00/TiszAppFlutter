import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/karaoke/karaoke_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/date_service.dart';

class KaraokeBasicViewModel extends ChangeNotifier {
  final List<KaraokeData> signedUpUsers = [];
  final database = FirebaseDatabase.instance.ref();

  void subscribeToUserChanges() async {
    database.child('karaoke/signed_up').onChildAdded.listen((event) {
      KaraokeData.fromSnapshot(event.snapshot).then((value) => {
            signedUpUsers.add(value),
            notifyListeners(),
          });
    });

    database.child('karaoke/signed_up').onChildRemoved.listen((event) {
      KaraokeData.fromSnapshot(event.snapshot).then((value) {
        final index = signedUpUsers
            .indexWhere((element) => element.user.uid == value.user.uid);
        if (index != -1) {
          signedUpUsers.removeAt(index);
        }
        notifyListeners();
      });
    });
  }

  void signUpForKaraoke() {
    final key = DateService.dateInMillisAsString();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    database.child('karaoke/signed_up/$key').set(uid);
  }

  void removeFromKaraoke(UserData user) {
    database.child('karaoke/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      final key = list.firstWhere((element) => element.value == user.uid).key;
      if (key != null) {
        database.child('karaoke/signed_up/$key').remove();
      }
    });
  }
}
