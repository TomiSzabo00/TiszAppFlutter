import 'package:tiszapp_flutter/helpers/try_cast.dart';

class Picture {
  String key;
  final String url;
  final String title;
  final String author;
  bool isPicOfTheDay;
  Map<String, String> likes;

  Picture({
    this.key = "0",
    required this.url,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
    this.likes = const {},
  });

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    final rawLikes = snapshot['likes']?.values.toList();
    Map<String, String> likes = {};
    if (rawLikes != null && rawLikes is Map) {
      likes = rawLikes.cast<String, String>();
    }
    return Picture(
      key: key,
      url: snapshot['fileName'],
      title: snapshot['title'],
      author: snapshot['author'],
      isPicOfTheDay: tryCast<bool>(snapshot['isPicOfTheDay']) ?? false,
      likes: likes,
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': url,
        'title': title,
        'author': author,
        'isPicOfTheDay': isPicOfTheDay,
        'likes': likes,
      };
}
