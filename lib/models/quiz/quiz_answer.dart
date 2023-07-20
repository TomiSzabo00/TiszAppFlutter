import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_solution.dart';

class QuizAnswer {
  final String author;
  final int teamNum;
  final List<QuizSolution> answers;

  QuizAnswer({
    required this.author,
    required this.teamNum,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'teamNum': teamNum,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }

  factory QuizAnswer.fromSnapshot(DataSnapshot snapshot) {
    var author = tryCast<String>(snapshot.child('author').value) ?? '';
    var teamNum = tryCast<int>(snapshot.child('teamNum').value) ?? -1;
    var answers = tryCast<List>(snapshot.child('answers').value)
            ?.map((e) => QuizSolution.fromJson(tryCast<Map>(e)))
            .toList() ??
        [];

    return QuizAnswer(
      author: author,
      teamNum: teamNum,
      answers: answers,
    );
  }
}
