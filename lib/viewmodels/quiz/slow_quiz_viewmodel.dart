import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class SlowQuizViewModel extends ChangeNotifier {
  final database = FirebaseDatabase.instance.ref();

  int numberOfQuestions = 0;
  List<TextEditingController> controllers = [];
  bool isSummary = false;
  int counter = 0;

  void initListeners() {
    database.child('slow_quiz/number_of_questions').onValue.listen((event) {
      numberOfQuestions = tryCast<int>(event.snapshot.value ?? 0) ?? 0;
      controllers =
          List.generate(numberOfQuestions, (index) => TextEditingController());
      notifyListeners();
    });

    database.child('slow_quiz/is_summary').onValue.listen((event) {
      isSummary = tryCast<bool>(event.snapshot.value ?? false) ?? false;
      notifyListeners();
    });

    database.child('slow_quiz').onChildRemoved.listen((event) {
      if (event.snapshot.key == 'answers') {
        controllers = List.generate(
            numberOfQuestions, (index) => TextEditingController());
        notifyListeners();
      }
    });
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
}
