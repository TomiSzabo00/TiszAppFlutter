import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_state.dart';

class QuizViewModel extends ChangeNotifier {
  var state = QuizState.disabled;

  bool get canSend => state == QuizState.enabled;

  void _updateState(QuizState newState) {
    state = newState;
    notifyListeners();
  }

  void send() {
    // TODO: implement send
    print('sent');
  }
}
