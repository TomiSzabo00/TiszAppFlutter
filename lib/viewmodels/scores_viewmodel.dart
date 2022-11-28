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
    score1: 0,
    score2: 0,
    score3: 0,
    score4: 0,
  );

  ScoresViewModel() {
    initializeDateFormatting();
  }

  void _addScoreToSum(Score score) {
    totalScore.score1 += score.score1;
    totalScore.score2 += score.score2;
    totalScore.score3 += score.score3;
    totalScore.score4 += score.score4;
  }

  void _resetSum() {
    totalScore.score1 = 0;
    totalScore.score2 = 0;
    totalScore.score3 = 0;
    totalScore.score4 = 0;
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
      score1: _scoreTextToInt(score1),
      score2: _scoreTextToInt(score2),
      score3: _scoreTextToInt(score3),
      score4: _scoreTextToInt(score4),
    );

    var ref = FirebaseDatabase.instance.ref().child("debug/scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());
  }

  int _scoreTextToInt(String text) {
    if (text == "") {
      return 0;
    } else {
      return int.tryParse(text) ?? 0;
    }
  }
}
