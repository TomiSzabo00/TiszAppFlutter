import 'package:firebase_database/firebase_database.dart';

class UserData {
  final String uid;
  final String name;
  final bool isAdmin;
  final int teamNum;

  UserData(
      {required this.uid,
      required this.name,
      required this.isAdmin,
      required this.teamNum});

  factory UserData.fromSnapshot(DataSnapshot snapshot) {
    return UserData(
        uid: (snapshot.value as Map)['uid'],
        name: (snapshot.value as Map)['userName'],
        isAdmin: (snapshot.value as Map)['admin'],
        teamNum: (snapshot.value as Map)['groupNumber']);
  }
}
