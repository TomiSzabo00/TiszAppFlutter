// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/score_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class ScoresViewModel with ChangeNotifier {
  List<Score> scores = [];

  int numberOfTeams = 4;

  Score totalScore = Score(
    author: '',
    name: 'Összesen',
    scores: List.generate(6, (_) => 0),
  );

  final nameController = TextEditingController();
  final List<TextEditingController> scoreControllers = List.generate(
    6,
    (_) => TextEditingController(),
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
    totalScore.scores = List.generate(numberOfTeams, (_) => 0);
  }

  Future<int> getNumberOfTeams() async {
    final num = await DatabaseService.getNumberOfTeams();
    scoreControllers.clear();
    scoreControllers.addAll(List.generate(num, (_) => TextEditingController()));
    return num;
  }

  void getScores() async {
    numberOfTeams = await getNumberOfTeams();
    scores.clear();
    _resetSum();
    final scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      final score = Score.fromSnapshot(event.snapshot);

      if (score.scores.length < numberOfTeams) {
        score.scores.addAll(
            List.generate(numberOfTeams - score.scores.length, (_) => 0));
      } else if (score.scores.length > numberOfTeams) {
        score.scores.removeRange(numberOfTeams, score.scores.length);
      }
      scores.add(score);
      _addScoreToSum(score);
      notifyListeners();
    });
  }

  void uploadScore() {
    var score = Score(
      author: FirebaseAuth.instance.currentUser!.uid,
      name: nameController.text,
      scores: _scoresTextToInt(scoreControllers.map((e) => e.text).toList()),
    );

    var ref = FirebaseDatabase.instance.ref().child("debug/scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());
    _clearControllers();
  }

  void _clearControllers() {
    nameController.clear();
    for (var element in scoreControllers) {
      element.clear();
    }
  }

  List<int> _scoresTextToInt(List<String> scores) {
    return scores.map((e) {
      if (e.isEmpty) {
        return 0;
      } else {
        return int.tryParse(e) ?? 0;
      }
    }).toList();
  }
}
