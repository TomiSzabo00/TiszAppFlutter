import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';

class Picture {
  String key;
  final String url;
  final String title;
  final String author;
  bool isPicOfTheDay;
  Map<PicReaction, int> reactions;

  Picture({
    this.key = "0",
    required this.url,
    required this.title,
    required this.author,
    this.isPicOfTheDay = false,
    Map<PicReaction, int>? reactions,
  }) : reactions = reactions ??
            {
              PicReaction.love: 0,
              PicReaction.funny: 0,
              PicReaction.sad: 0,
              PicReaction.angry: 0,
            };

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    final rawReactions = tryCast<Map>(snapshot['reactions']) ?? {};
    Map<PicReaction, int> reactions = rawReactions.map((key, value) {
      key = key.toString().toPicReaction;
      value = tryCast<int>(value) ?? 0;
      return MapEntry(key, value);
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
    final Map<String, int> reaccMap = reactions.map((key, value) {
      final newKey = key.name;
      return MapEntry(newKey, value);
    });
    return {
      'url': url,
      'title': title,
      'author': author,
      'isPicOfTheDay' : isPicOfTheDay,
      'reactions': reaccMap,
    };
  }
}
