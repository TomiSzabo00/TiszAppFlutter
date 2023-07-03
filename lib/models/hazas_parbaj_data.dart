import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class HazasParbajData {
  final UserData user;
  final String name1;
  final String name2;
  final int team;
  bool votedOut = false;

  HazasParbajData(
      {required this.user,
      required this.name1,
      required this.name2,
      required this.team,
      this.votedOut = false});

  static Future<HazasParbajData> fromSnapshot(DataSnapshot snapshot) async {
    final uid =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['user']) ?? "";
    final user = await DatabaseService.getUserData(uid);
    final name1 =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['name1']) ?? "";
    final name2 =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['name2']) ?? "";
    final team =
        tryCast<int>((tryCast<Map>(snapshot.value) ?? {})['team']) ?? 0;
    final votedOut =
        tryCast<bool>((tryCast<Map>(snapshot.value) ?? {})['votedOut']) ??
            false;
    return HazasParbajData(
      user: user,
      name1: name1,
      name2: name2,
      team: team,
      votedOut: votedOut,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.uid,
        'name1': name1,
        'name2': name2,
        'team': team,
        'votedOut': votedOut
      };
}
