import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer_state.dart';

class QuizSolution {
  final String solution;
  QuizAnswerState state;

  QuizSolution({
    required this.solution,
    this.state = QuizAnswerState.na,
  });

  factory QuizSolution.fromSnapshot(DataSnapshot? snapshot) {
    if (snapshot == null) {
      return QuizSolution(
        solution: '<üres volt>',
        state: QuizAnswerState.na,
      );
    }
    var solution = tryCast<String>(snapshot.child('solution').value) ?? '';
    solution = solution.trim() == '' ? '<üres volt>' : solution;
    var state = (tryCast<String>(snapshot.child('state').value) ?? '')
        .toQuizAnswerState;

    return QuizSolution(
      solution: solution,
      state: state,
    );
  }

  factory QuizSolution.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return QuizSolution(
        solution: '<üres volt>',
        state: QuizAnswerState.na,
      );
    }
    var solution = tryCast<String>(json['solution']) ?? '<üres volt>';
    var state = (tryCast<String>(json['state']) ?? '').toQuizAnswerState;
    return QuizSolution(
      solution: solution,
      state: state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solution': solution,
      'state': state.name,
    };
  }
}
