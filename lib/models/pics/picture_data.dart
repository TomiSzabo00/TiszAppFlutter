import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class Picture {
  String key;
  final List<String> urls;
  final String title;
  final String author;
  bool isPicOfTheDay;
  Map<String, String> likes;
  List<Map<String, String>> comments = [];
  PictureCategory category = PictureCategory.general;

  Picture({
    required this.key,
    required this.urls,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
    this.likes = const {},
    this.comments = const [],
    this.category = PictureCategory.general,
  });

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    final rawUrls = snapshot['imageUrls']?.toList();
    List<String> urls = [];
    if (rawUrls != null && rawUrls is List) {
      urls = rawUrls.cast<String>();
    }

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
      urls: urls,
      title: snapshot['title'],
      author: snapshot['author'],
      isPicOfTheDay: tryCast<bool>(snapshot['isPicOfTheDay']) ?? false,
      likes: likes,
      comments: comments,
      category: snapshot['category'].toString().toCategory,
    );
  }

  Map<String, dynamic> toJson() => {
        'imageUrls': urls,
        'title': title,
        'author': author,
        'isPicOfTheDay': isPicOfTheDay,
        'likes': likes,
        'comments': comments,
        'category': category.name,
      };
}
