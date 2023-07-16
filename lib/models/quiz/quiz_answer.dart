import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class QuizAnswer {
  final String author;
  final int teamNum;
  final List<String> answers;

  QuizAnswer({
    required this.author,
    required this.teamNum,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'teamNum': teamNum,
      'answers': answers,
    };
  }

  factory QuizAnswer.fromSnapshot(DataSnapshot snapshot) {
    var author = tryCast<String>(snapshot.child('author').value) ?? '';
    var teamNum = tryCast<int>(snapshot.child('teamNum').value) ?? -1;
    var rawAnswers = tryCast<List>(snapshot.child('answers').value) ?? [];
    var answers = rawAnswers.map((e) => tryCast<String>(e) ?? '').toList();
    answers = answers.map((e) => e.trim() == '' ? '<üresen hagyta>' : e).toList();

    return QuizAnswer(
      author: author,
      teamNum: teamNum,
      answers: answers,
    );
  }
}
