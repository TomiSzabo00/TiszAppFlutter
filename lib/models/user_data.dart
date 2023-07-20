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
      uid: tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['uid']) ?? "",
      name: tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['userName']) ??
          "",
      isAdmin:
          tryCast<bool>((tryCast<Map>(snapshot.value) ?? {})['admin']) ?? false,
      teamNum:
          tryCast<int>((tryCast<Map>(snapshot.value) ?? {})['groupNumber']) ??
              -1,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userName': name,
        'admin': isAdmin,
        'groupNumber': teamNum,
      };

  factory UserData.empty() {
    return UserData(uid: '', name: 'ismeretlen', isAdmin: false, teamNum: -1);
  }
}
