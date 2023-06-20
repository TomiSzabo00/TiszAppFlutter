import 'package:flutter/material.dart';

class QuizViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void incrementIndex() {
    _currentIndex++;
    notifyListeners();
  }
}
