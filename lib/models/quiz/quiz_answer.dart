import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class QuizAnswer {
  final int teamNum;
  final List<String> answers;

  QuizAnswer({
    required this.teamNum,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'teamNum': teamNum,
      'answers': answers,
    };
  }

  factory QuizAnswer.fromSnapshot(DataSnapshot snapshot) {
    var teamNum = tryCast<int>(snapshot.child('teamNum').value) ?? -1;
    var answers =
        tryCast<List<String>>(snapshot.child('answers').value) ?? List.empty();
    return QuizAnswer(
      teamNum: teamNum,
      answers: answers,
    );
  }
}
