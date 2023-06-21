import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class UserData {
  String uid;
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
        uid: (tryCast<Map>(snapshot.value) ?? {})['uid'],
        name: (tryCast<Map>(snapshot.value) ?? {})['userName'],
        isAdmin: (tryCast<Map>(snapshot.value) ?? {})['admin'],
        teamNum: (tryCast<Map>(snapshot.value) ?? {})['groupNumber']);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userName': name,
        'admin': isAdmin,
        'groupNumber': teamNum,
      };
}
