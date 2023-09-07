import 'package:tiszapp_flutter/helpers/try_cast.dart';

class TinderData {
  final String uid;
  final String name;
  final int teamNum;
  final String? imageUrl;

  TinderData({
    required this.uid,
    required this.name,
    required this.teamNum,
    this.imageUrl,
  });

  factory TinderData.fromJson(String key, Map<dynamic, dynamic> json) {
    return TinderData(
      uid: tryCast<String>(key) ?? '',
      name: tryCast<String>(json['name']) ?? '',
      teamNum: tryCast<int>(json['teamNum']) ?? -1,
      imageUrl: tryCast<String>(json['imageUrl']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teamNum': teamNum,
      'imageUrl': imageUrl,
    };
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TinderData &&
        other.uid == uid &&
        other.name == name &&
        other.teamNum == teamNum &&
        other.imageUrl == imageUrl;
  }
}
