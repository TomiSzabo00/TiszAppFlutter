import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/models/score_data.dart';

class ScoresViewModel with ChangeNotifier {
  List<Score> scores = [];

  ScoresViewModel() {
    _getScores();
  }

  void _getScores() {
    final scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      scores.insert(0, Score.fromSnapshot(event.snapshot));
      notifyListeners();
    });
  }
}
