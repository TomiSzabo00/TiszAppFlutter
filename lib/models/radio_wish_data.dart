import 'package:firebase_database/firebase_database.dart';

class RadioWish {
  String key;
  final String name;
  final String url;
  final String user;

  RadioWish({required this.key, required this.name, required this.url, required this.user});

  factory RadioWish.fromSnapshot(String key, DataSnapshot snapshot) => RadioWish(
        key: key,
        name: (snapshot.value as Map<Object?, Object?>)['name'] as String,
        url: (snapshot.value as Map<Object?, Object?>)['url'] as String,
        user: (snapshot.value as Map<Object?, Object?>)['user'] as String,
      );

    Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
        "user": user,
      };
}