import 'package:firebase_database/firebase_database.dart';

class TextData {
  String key;
  final String title;
  final String text;
  final String author;

  TextData(
      {this.key = "0",
      required this.title,
      required this.text,
      required this.author});

  factory TextData.fromSnapshot(String key, DataSnapshot snapshot) => TextData(
        key: key,
        title: (snapshot.value as Map<Object?, Object?>)['title'] as String,
        text: (snapshot.value as Map<Object?, Object?>)['text'] as String,
        author: (snapshot.value as Map<Object?, Object?>)['author'] as String,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "text": text,
        "author": author,
      };
}
