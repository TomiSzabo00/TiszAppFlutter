import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class UserData {
  String uid;
  final String name;
  final bool isAdmin;
  final int teamNum;
  String profilePictureUrl;

  static const defaultUrl = 'https://firebasestorage.googleapis.com/v0/b/tiszapp-175fb.appspot.com/o/profile_pictures%2Fdefault.jpg?alt=media&token=51830fc5-17d3-46f1-9ddf-3265656dea48';

  UserData({
    required this.uid,
    required this.name,
    required this.isAdmin,
    required this.teamNum,
    required this.profilePictureUrl,
  });

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
      profilePictureUrl: tryCast<String>(
              (tryCast<Map>(snapshot.value) ?? {})['profilePictureUrl']) ??
          defaultUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userName': name,
        'admin': isAdmin,
        'groupNumber': teamNum,
        'profilePictureUrl': profilePictureUrl,
      };

  factory UserData.empty() {
    return UserData(uid: '', name: 'ismeretlen', isAdmin: false, teamNum: -1, profilePictureUrl: defaultUrl);
  }

  String get teamNumberAsString {
    if (teamNum == 0) {
      return 'Szervező';
    } else {
      return '$teamNum. csapat';
    }
  }
}

extension TeamNumStringExtension on int {
  String get teamNumberAsString {
    if (this == 0) {
      return 'Szervező';
    } else {
      return '$this. csapat';
    }
  }
}
