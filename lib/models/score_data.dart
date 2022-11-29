import 'package:firebase_database/firebase_database.dart';

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
      : author = (snapshot.value as Map<Object?, Object?>)['author'] as String,
        name = (snapshot.value as Map<Object?, Object?>)['name'] as String,
        scores = ((snapshot.value as Map<Object?, Object?>)['scores']
                as List<Object?>)
            .map((e) => e as int)
            .toList();

  Map<String, dynamic> toJson() => {
        'author': author,
        'name': name,
        'scores': scores,
      };
}
