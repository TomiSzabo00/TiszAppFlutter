import 'package:firebase_database/firebase_database.dart';

class Score {
  final String author;
  final String name;
  final int score1;
  final int score2;
  final int score3;
  final int score4;

  Score({
    required this.author,
    required this.name,
    required this.score1,
    required this.score2,
    required this.score3,
    required this.score4,
  });

  Score.fromJson(Map<String, dynamic> json)
      : author = json['author'],
        name = json['name'],
        score1 = json['score1'],
        score2 = json['score2'],
        score3 = json['score3'],
        score4 = json['score4'];

  Score.fromSnapshot(DataSnapshot snapshot)
      : author = (snapshot.value as Map<Object?, Object?>)['author'] as String,
        name = (snapshot.value as Map<Object?, Object?>)['name'] as String,
        score1 = (snapshot.value as Map<Object?, Object?>)['score1'] as int,
        score2 = (snapshot.value as Map<Object?, Object?>)['score2'] as int,
        score3 = (snapshot.value as Map<Object?, Object?>)['score3'] as int,
        score4 = (snapshot.value as Map<Object?, Object?>)['score4'] as int;

  Map<String, dynamic> toJson() => {
        'author': author,
        'name': name,
        'score1': score1,
        'score2': score2,
        'score3': score3,
        'score4': score4,
      };
}
