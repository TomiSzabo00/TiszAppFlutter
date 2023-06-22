import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class KaraokeData {
  final UserData user;
  final String music;

  KaraokeData({required this.user, required this.music});

  static Future<KaraokeData> fromSnapshot(DataSnapshot snapshot) async {
    final uid =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['user']) ?? "";
    final user = await DatabaseService.getUserData(uid);
    final music =
        tryCast<String>((tryCast<Map>(snapshot.value) ?? {})['music']) ?? "";
    return KaraokeData(
      user: user,
      music: music,
    );
  }

  Map<String, String> toJson() => {
        'user': user.uid,
        'music': music,
      };
}
