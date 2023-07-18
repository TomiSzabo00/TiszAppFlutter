import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';

class Picture {
  String key;
  final String url;
  final String title;
  final String author;
  bool isPicOfTheDay;

  Picture({
    this.key = "0",
    required this.url,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
  });

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    return Picture(
      key: key,
      url: snapshot['fileName'],
      title: snapshot['title'],
      author: snapshot['author'],
      isPicOfTheDay: tryCast<bool>(snapshot['isPicOfTheDay']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': url,
        'title': title,
        'author': author,
        'isPicOfTheDay': isPicOfTheDay,
      };
}
