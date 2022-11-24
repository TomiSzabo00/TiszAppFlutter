// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/models/score_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScoresViewModel with ChangeNotifier {
  List<Score> scores = [];

  ScoresViewModel() {
    initializeDateFormatting();
    _getScores();
  }

  void _getScores() {
    final scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      scores.insert(0, Score.fromSnapshot(event.snapshot));
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
