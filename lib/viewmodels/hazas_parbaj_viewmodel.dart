import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/hazas_parbaj_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

import '../services/date_service.dart';

class HazasParbajViewModel extends ChangeNotifier {
  final List<HazasParbajData> signedUpPairs = [];
  final database = FirebaseDatabase.instance.ref();
  final name1Controller = TextEditingController();
  final name2Controller = TextEditingController();
  final teamController = TextEditingController();

  void subscribeToUserChanges() async {
    database.child('hazas_parbaj/signed_up').onChildAdded.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) => {
            if (!signedUpPairs.any((element) =>
                (element.user.uid == value.user.uid &&
                    element.name1 == value.name1 &&
                    element.name2 == value.name2 &&
                    element.team == value.team)))
              signedUpPairs.add(value),
            notifyListeners(),
          });
    });

    database.child('hazas_parbaj/signed_up').onChildRemoved.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) {
        final idx = signedUpPairs.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team));
        if (idx != -1) {
          signedUpPairs.removeAt(idx);
        }
        notifyListeners();
      });
    });

    database.child('hazas_parbaj/signed_up').onChildChanged.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) {
        final idx = signedUpPairs.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team));
        if (idx != -1) {
          signedUpPairs[idx] = value;
        }
        notifyListeners();
      });
    });
  }

  Future<bool> signUpForKaraoke() async {
    final key = DateService.dateInMillisAsString();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await DatabaseService.getUserData(uid);
    final data = HazasParbajData(
        user: userData,
        name1: name1Controller.text,
        name2: name2Controller.text,
        team: (tryCast<int>(teamController.text) ?? -1));
    final index = signedUpPairs.indexWhere((element) =>
        (element.user.uid == userData.uid &&
            element.name1 == name1Controller.text &&
            element.name2 == name2Controller.text &&
            element.team == (tryCast<int>(teamController.text) ?? -1)));
    if (index != -1) {
      notifyListeners();
      return true;
    }
    database.child('hazas_parbaj/signed_up/$key').set(data);
    name1Controller.clear();
    name2Controller.clear();
    teamController.clear();
    return false;
  }

  void removeFromPairs(HazasParbajData data) {
    database.child('hazas_parbaj/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        HazasParbajData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid &&
                  value.name1 == data.name1 &&
                  value.name2 == data.name2 &&
                  value.team == data.team)
                database.child('hazas_parbaj/signed_up/${e.key}').remove()
            });
      }
    });
  }
}
