import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer_state.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_solution.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class SlowQuizViewModel extends ChangeNotifier {
  final database = DatabaseService.database;

  int numberOfQuestions = 0;
  List<TextEditingController> controllers = [];
  bool isSummary = false;
  int counter = 0;
  bool didSendAnswers = false;

  List<List<QuizAnswer>> answersByTeams = [];

  List<double> get scores {
    return answersByTeams
        .map((e) =>
            e.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue +
                    element.answers.fold<double>(
                        0,
                        (previousValue2, element2) =>
                            previousValue2 +
                            (element2.state == QuizAnswerState.correct
                                ? 1
                                : element2.state ==
                                        QuizAnswerState.partiallyCorrect
                                    ? 0.5
                                    : 0))) /
            e.length)
        .toList();
  }

  void initListeners() {
    answersByTeams.clear();
    didSendAnswers = false;
    isSummary = false;
    database.child('slow_quiz/number_of_questions').onValue.listen((event) {
      numberOfQuestions = tryCast<int>(event.snapshot.value ?? 0) ?? 0;
      controllers =
          List.generate(numberOfQuestions, (index) => TextEditingController());
      notifyListeners();
    });

    database.child('slow_quiz/is_summary').onValue.listen((event) {
      isSummary = tryCast<bool>(event.snapshot.value ?? false) ?? false;
      if (isSummary) {
        if (controllers.any((element) => element.text.isNotEmpty)) {
          sendAnswers();
        }
      }
      notifyListeners();
    });

    database.child('slow_quiz').onChildRemoved.listen((event) {
      if (event.snapshot.key == 'answers') {
        didSendAnswers = false;
        answersByTeams = [];
        resetControllers();
      }
    });

    database.child('slow_quiz/answers').onChildAdded.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.key == FirebaseAuth.instance.currentUser!.uid) {
        didSendAnswers = true;
      }
      final answer = QuizAnswer.fromSnapshot(event.snapshot);
      final teamIndex = answersByTeams.indexWhere((element) =>
          element.any((element) => element.teamNum == answer.teamNum));
      if (teamIndex == -1) {
        answersByTeams.add([answer]);
      } else {
        if (answersByTeams[teamIndex]
            .any((element) => element.author == answer.author)) {
          return;
        }
        answersByTeams[teamIndex].add(answer);
      }
      notifyListeners();
    });

    database.child('slow_quiz/answers').onChildChanged.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      final answer = QuizAnswer.fromSnapshot(event.snapshot);
      final teamNum = answer.teamNum;
      final teamIndex = answersByTeams.indexWhere(
          (element) => element.any((element) => element.teamNum == teamNum));
      final answerIndex = answersByTeams[teamIndex]
          .indexWhere((element) => element.author == answer.author);
      answersByTeams[teamIndex][answerIndex] = answer;
      notifyListeners();
    });
  }

  void resetControllers() {
    controllers =
        List.generate(numberOfQuestions, (index) => TextEditingController());
    notifyListeners();
  }

  void incrementCounter() {
    counter++;
    notifyListeners();
  }

  void decrementCounter() {
    if (counter > 0) {
      counter--;
      notifyListeners();
    }
  }

  void startQuiz() {
    database.child('slow_quiz/is_summary').set(false);
    database.child('slow_quiz/number_of_questions').set(counter);
    database.child('slow_quiz/answers').remove();
  }

  void deleteQuiz() {
    database.child('slow_quiz').remove();
  }

  void resetAnswers() {
    database.child('slow_quiz/answers').remove();
  }

  void toggleQuizState() {
    database.child('slow_quiz/is_summary').set(!isSummary);
  }

  void sendAnswers() async {
    if (controllers.every((element) => element.text.isEmpty)) {
      return;
    }
    final currUser = await DatabaseService.getUserData(
        FirebaseAuth.instance.currentUser!.uid);
    final answers =
        controllers.map((e) => QuizSolution(solution: e.text)).toList();
    final answer = QuizAnswer(
      author: currUser.uid,
      teamNum: currUser.teamNum,
      answers: answers,
    );
    database.child('slow_quiz/answers/${currUser.uid}').set(answer.toJson());
    resetControllers();
  }

  String getScoreFor(int index) {
    if (scores.length < index) {
      return '0';
    }
    final score = scores[index];
    if (score == score.round()) {
      return score.round().toString();
    }
    return scores[index].toString();
  }

  Color getBackgroundForAnswers(int teamNum, int index) {
    if (answersByTeams.length <= teamNum) {
      return Colors.white;
    }
    final states = answersByTeams[teamNum];
    final state = states.first.answers[index].state;
    if (state == QuizAnswerState.correct) {
      return Colors.green;
    }
    if (state == QuizAnswerState.partiallyCorrect) {
      return Colors.orange;
    }
    if (state == QuizAnswerState.incorrect) {
      return Colors.red;
    }
    return Colors.white;
  }

  void setAnswersCorrect(int index, int answerIndex) {
    if (answersByTeams.length <= answerIndex) {
      return;
    }
    final states = answersByTeams[answerIndex];
    for (int i = 0; i < states.length; i++) {
      states[i].answers[index].state = QuizAnswerState.correct;
    }
    updateAnswers();
    notifyListeners();
  }

  void setAnswersIncorrect(int index, int answerIndex) {
    if (answersByTeams.length <= answerIndex) {
      return;
    }
    final states = answersByTeams[answerIndex];
    for (int i = 0; i < states.length; i++) {
      states[i].answers[index].state = QuizAnswerState.incorrect;
    }
    updateAnswers();
    notifyListeners();
  }

  void setAnswersPartiallyCorrect(int index, int answerIndex) {
    if (answersByTeams.length <= answerIndex) {
      return;
    }
    final states = answersByTeams[answerIndex];
    for (int i = 0; i < states.length; i++) {
      states[i].answers[index].state = QuizAnswerState.partiallyCorrect;
    }
    updateAnswers();
    notifyListeners();
  }

  void updateAnswers() {
    for (var teams in answersByTeams) {
      for (var answer in teams) {
        database
            .child('slow_quiz/answers/${answer.author}')
            .set(answer.toJson());
      }
    }
  }
}
