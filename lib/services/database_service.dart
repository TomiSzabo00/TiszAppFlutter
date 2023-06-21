import 'package:firebase_database/firebase_database.dart' as database;
import 'package:tiszapp_flutter/models/user_data.dart';

// Insert globally used database getters here. E.x.: getNumberOfTeams() or getFirstDay()

class DatabaseService {
  static database.DatabaseReference ref =
      database.FirebaseDatabase.instance.ref();

  static Future<int> getNumberOfTeams() async {
    final snapshot = await ref.child('number_of_teams').get();
    if (snapshot.exists) {
      return snapshot.value as int;
    }
    return 4;
  }

  static Future<UserData> getUserData(String uid) async {
    return await ref.child('users/$uid').get().then((snapshot) {
      if (snapshot.value != null) {
        return UserData.fromSnapshot(snapshot);
      }
      return UserData(uid: "", name: "Error", isAdmin: false, teamNum: -1);
    });
  }
}
