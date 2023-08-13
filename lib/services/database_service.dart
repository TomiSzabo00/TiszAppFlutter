import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

// Insert globally used database getters here. E.x.: getNumberOfTeams() or getFirstDay()

class DatabaseService {
  static get database {
    if (kDebugMode) {
      return FirebaseDatabase.instance.ref().child('debug');
    } else {
      return FirebaseDatabase.instance.ref();
    }
  }

  static Future<int> getNumberOfTeams() async {
    final snapshot = await database.child('number_of_teams').get();
    if (snapshot.exists) {
      return tryCast<int>(snapshot.value) ?? 4;
    }
    return 4;
  }

  static Future<UserData> getUserData(String uid) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return UserData(uid: "", name: "Error", isAdmin: false, teamNum: -1);
    }
    return await FirebaseDatabase.instance
        .ref()
        .child('users/$uid')
        .get()
        .then((snapshot) {
      if (snapshot.value != null) {
        return UserData.fromSnapshot(snapshot);
      }
      return UserData(uid: "", name: "Error", isAdmin: false, teamNum: -1);
    });
  }

  static Future<String> getDriveURL({required int teamNum}) {
    return database
        .child('porty_drive_links/$teamNum')
        .get()
        .then((snapshot) => tryCast<String>(snapshot.value) ?? "");
  }
}
