import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class KaraokeData {
  final UserData user;
  final String music;
  bool didPlay = false;

  KaraokeData({required this.user, required this.music, this.didPlay = false});

  static Future<KaraokeData> fromSnapshot(DataSnapshot snapshot) async {
    final uid =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['user']) ?? "";
    final user = await DatabaseService.getUserData(uid);
    final music =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['music']) ?? "";
    final didPlay =
        tryCast<bool>((tryCast<Map>(snapshot.value) ?? {})['didPlay']) ?? false;
    return KaraokeData(
      user: user,
      music: music,
      didPlay: didPlay,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.uid,
        'music': music,
        'didPlay': didPlay
      };
}
