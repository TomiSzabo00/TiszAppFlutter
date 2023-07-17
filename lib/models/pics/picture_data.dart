import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';

class Picture {
  String key;
  final String url;
  final String title;
  final String author;
  bool isPicOfTheDay;
  Map<PicReaction, List<String>> reactions;

  Picture({
    this.key = "0",
    required this.url,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
    Map<PicReaction, List<String>>? reactions,
  }) : reactions = reactions ??
            {
              PicReaction.love: [''],
              PicReaction.funny: [''],
              PicReaction.sad: [''],
              PicReaction.angry: [''],
            };

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    final rawReactions = tryCast<Map>(snapshot['reactions']) ?? {};
    Map<PicReaction, List<String>> reactions = rawReactions.map((key, value) {
      key = key.toString().toPicReaction;
      List<String> newValue = (tryCast<List>(value) ?? []).map((e) => e.toString()).toList();
      return MapEntry(key, newValue);
    });

    return Picture(
      key: key,
      url: snapshot['fileName'],
      title: snapshot['title'],
      author: snapshot['author'],
      isPicOfTheDay: tryCast<bool>(snapshot['isPicOfTheDay']) ?? false,
      reactions: reactions,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, List<String>> reaccMap = reactions.map((key, value) {
      final newKey = key.name;
      return MapEntry(newKey, value);
    });
    return {
      'fileName': url,
      'title': title,
      'author': author,
      'isPicOfTheDay' : isPicOfTheDay,
      'reactions': reaccMap,
    };
  }
}
