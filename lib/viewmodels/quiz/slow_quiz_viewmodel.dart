import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_answer.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class SlowQuizViewModel extends ChangeNotifier {
  final database = FirebaseDatabase.instance.ref();

  int numberOfQuestions = 0;
  List<TextEditingController> controllers = [];
  bool isSummary = false;
  int counter = 0;
  bool didSendAnswers = false;

  List<List<QuizAnswer>> answersByTeams = [];

  void initListeners() {
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
        Future.delayed(const Duration(seconds: 1)).then((value) {
          getAnswers();
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    });

    database.child('slow_quiz').onChildRemoved.listen((event) {
      if (event.snapshot.key == 'answers') {
        didSendAnswers = false;
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

  void stopQuiz() {
    database.child('slow_quiz/is_summary').set(true);
  }

  void getAnswers() {
    database.child('slow_quiz/answers').once().then((event) {
      if (event.snapshot.value == null) {
        return;
      }
      final answers =
          event.snapshot.children.map((e) => QuizAnswer.fromSnapshot(e)).toList();
      answers.sort((a, b) => a.teamNum.compareTo(b.teamNum));
      answersByTeams = List.generate(
          answers.last.teamNum,
          (index) => answers
              .where((element) => element.teamNum == index + 1)
              .toList());
      notifyListeners();
    });
  }

  void sendAnswers() async {
    if (controllers.every((element) => element.text.isEmpty)) {
      return;
    }
    final currUser = await DatabaseService.getUserData(
        FirebaseAuth.instance.currentUser!.uid);
    final answers = controllers.map((e) => e.text).toList();
    final answer = QuizAnswer(
      teamNum: currUser.teamNum,
      answers: answers,
    );
    database.child('slow_quiz/answers/${currUser.uid}').set(answer.toJson());
    resetControllers();
  }
}
