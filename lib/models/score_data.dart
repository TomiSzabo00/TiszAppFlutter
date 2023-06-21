import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class Score {
  final String author;
  final String name;
  List<int> scores;

  Score({
    required this.author,
    required this.name,
    required this.scores,
  });

  Score.fromJson(Map<String, dynamic> json)
      : author = json['author'],
        name = json['name'],
        scores = json['score1'];

  Score.fromSnapshot(DataSnapshot snapshot)
      : author = tryCast<String>(
                (tryCast<Map<Object?, Object?>>(snapshot.value) ??
                    {})['author']) ??
            "",
        name = tryCast<String>(
                (tryCast<Map<Object?, Object?>>(snapshot.value) ??
                    {})['name']) ??
            "",
        scores = (tryCast<List<Object?>>(
                    (tryCast<Map<Object?, Object?>>(snapshot.value) ??
                        {})['scores']) ??
                [])
            .map((e) => tryCast<int>(e) ?? 0)
            .toList();

  Map<String, dynamic> toJson() => {
        'author': author,
        'name': name,
        'scores': scores,
      };
}
