import 'package:firebase_database/firebase_database.dart' as database;

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
}
