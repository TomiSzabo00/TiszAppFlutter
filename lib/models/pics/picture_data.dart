import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class Picture {
  String key;
  final String url;
  final String title;
  final String author;
  bool isPicOfTheDay;
  Map<String, String> likes;
  List<Map<String, String>> comments = [];
  PictureCategory category = PictureCategory.general;

  Picture({
    this.key = "0",
    required this.url,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
    this.likes = const {},
    this.comments = const [],
    this.category = PictureCategory.general,
  });

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    final rawLikes = snapshot['likes']?.values.toList();
    Map<String, String> likes = {};
    if (rawLikes != null && rawLikes is Map) {
      likes = rawLikes.cast<String, String>();
    }
    final rawComments = snapshot['comments'];
    List orderedRawComments = [];
    if (rawComments != null && rawComments is Map) {
      orderedRawComments = rawComments.orderByKeys(compareTo: (a, b) => a.compareTo(b)).values.toList();
    }
    List<Map<String, String>> comments = [];
    if (orderedRawComments.isNotEmpty) {
      for (var element in orderedRawComments) {
        if (element is Map) {
          comments.add(element.cast<String, String>());
        }
      }
    }
    return Picture(
      key: key,
      url: snapshot['fileName'],
      title: snapshot['title'],
      author: snapshot['author'],
      isPicOfTheDay: tryCast<bool>(snapshot['isPicOfTheDay']) ?? false,
      likes: likes,
      comments: comments,
      category: snapshot['category'].toString().toCategory,
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': url,
        'title': title,
        'author': author,
        'isPicOfTheDay': isPicOfTheDay,
        'likes': likes,
        'comments': comments,
        'category': category.name,
      };
}
