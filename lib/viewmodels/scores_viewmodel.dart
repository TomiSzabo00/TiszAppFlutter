// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/models/score_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScoresViewModel with ChangeNotifier {
  List<Score> scores = [];
  Score totalScore = Score(
    author: '',
    name: 'Összesen',
    scores: List.generate(4, (_) => 0),
  );

  ScoresViewModel() {
    initializeDateFormatting();
  }

  void _addScoreToSum(Score score) {
    for (int i = 0; i < score.scores.length; i++) {
      totalScore.scores[i] += score.scores[i];
    }
  }

  void _resetSum() {
    totalScore.scores = List.generate(4, (_) => 0);
  }

  void getScores() {
    scores.clear();
    _resetSum();
    final scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      final score = Score.fromSnapshot(event.snapshot);
      scores.insert(0, score);
      _addScoreToSum(score);
      notifyListeners();
    });
  }

  void uploadScore(
      String name, String score1, String score2, String score3, String score4) {
    var score = Score(
      author: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      scores: _scoresTextToInt([score1, score2, score3, score4]),
    );

    var ref = FirebaseDatabase.instance.ref().child("debug/scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());
  }

  List<int> _scoresTextToInt(List<String> scores) {
    return scores.map((e) {
      if (e.isEmpty) {
        return 0;
      } else {
        return int.parse(e);
      }
    }).toList();
  }
}
