// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/scores/distribution_type.dart';
import 'package:tiszapp_flutter/models/scores/score_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class ScoresViewModel with ChangeNotifier {
  List<Score> scores = [];

  int numberOfTeams = 4;

  DistributionType? chosenDistr;

  Score totalScore = Score(
    author: '',
    name: 'Összesen',
    scores: List.generate(6, (_) => 0),
  );

  final nameController = TextEditingController();
  List<TextEditingController> scoreControllers = [];
  final maxController = TextEditingController();
  List<TextEditingController> finalScoreControllers = [];
  bool areAllScoresAdded = false;
  StreamSubscription<DatabaseEvent>? scoresSubscription;

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
    if (scoreControllers.isEmpty) {
      scoreControllers
          .addAll(List.generate(num, (_) => TextEditingController()));
    }
    if (finalScoreControllers.isEmpty) {
      finalScoreControllers
          .addAll(List.generate(num, (_) => TextEditingController()));
    }
    numberOfTeams = num;
    notifyListeners();
    return num;
  }

  void getScores() async {
    await getNumberOfTeams();
    scores.clear();
    _resetSum();
    scoresSubscription?.cancel();
    final scoresRef = DatabaseService.database.child("scores");
    scoresSubscription = scoresRef.onChildAdded.listen((event) {
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

  bool allFinalScoresFilled() {
    for (var element in finalScoreControllers) {
      if (element.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void uploadScore() {
    var score = allFinalScoresFilled()
        ? Score(
            author: FirebaseAuth.instance.currentUser!.uid,
            name: nameController.text,
            scores: _scoresTextToInt(
                finalScoreControllers.map((e) => e.text).toList()),
          )
        : Score(
            author: FirebaseAuth.instance.currentUser!.uid,
            name: nameController.text,
            scores:
                _scoresTextToInt(scoreControllers.map((e) => e.text).toList()),
          );

    var ref = DatabaseService.database.child("scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());
    _clearControllers();
  }

  void _clearControllers() {
    dev.log("Clearing controllers");
    nameController.clear();
    maxController.clear();
    for (var element in scoreControllers) {
      element.clear();
    }
    for (var element in finalScoreControllers) {
      element.clear();
    }
    chosenDistr = null;
    areAllScoresAdded = false;
    notifyListeners();
  }

  List<int> _scoresTextToInt(List<String> scores) {
    dev.log("Converting scores to int");
    return scores.map((e) {
      if (e.isEmpty) {
        return 0;
      } else {
        return int.tryParse(e) ?? 0;
      }
    }).toList();
  }

  List<DistributionType> getAvailableDistrs() {
    dev.log("Getting available distributions");
    return [
      DistributionType.none,
      DistributionType.proportional,
      DistributionType.spreadOut
    ];
  }

  chooseDistr(DistributionType? s) {
    dev.log("Choosing distribution");
    switch (s) {
      case DistributionType.none:
        setNone();
        break;
      case DistributionType.proportional:
        setProportional();
        break;
      case DistributionType.spreadOut:
        setSpreadOut();
        break;
      default:
        setNone();
    }
  }

  void areBaseScoresAdded() {
    dev.log("Checking if base scores are added");
    for (var element in scoreControllers) {
      if (element.text.isEmpty) {
        areAllScoresAdded = false;
        notifyListeners();
        return;
      }
    }
    areAllScoresAdded = true;
    notifyListeners();
  }

  void setNone() {
    dev.log("Setting distribution to none");
    chosenDistr = DistributionType.none;
    for (int i = 0; i < scoreControllers.length; i++) {
      finalScoreControllers[i].text = scoreControllers[i].text;
    }
    notifyListeners();
  }

  void setProportional() {
    dev.log("Setting distribution to proportional");
    chosenDistr = DistributionType.proportional;
    List<int> values = [];
    for (var scoreController in scoreControllers) {
      values.add(int.parse(scoreController.value.text));
    }
    final maxVal = values.reduce(max);
    for (int i = 0; i < scoreControllers.length; i++) {
      finalScoreControllers[i].text =
          (values[i] / maxVal * (int.tryParse(maxController.value.text) ?? 100))
              .round()
              .toString();
    }
    notifyListeners();
  }

  void setSpreadOut() {
    dev.log("Setting distribution to spread out");
    chosenDistr = DistributionType.spreadOut;
    final ranks = [];
    for (int i = 0; i < scoreControllers.length; i++) {
      int cnt = 0;
      for (int j = 0; j < scoreControllers.length; j++) {
        if (int.parse(scoreControllers[i].value.text) >
            int.parse(scoreControllers[j].value.text)) {
          cnt++;
        }
      }
      ranks.add(cnt);
    }
    dev.log(ranks.toString());
    for (int i = 0; i < finalScoreControllers.length; i++) {
      finalScoreControllers[i].text =
          ((int.tryParse(maxController.value.text) ?? 100) *
                  (ranks[i] + 1) /
                  finalScoreControllers.length)
              .round()
              .toString();
    }
    notifyListeners();
  }

  maxChanged() {
    dev.log("Max changed");
    if (!areAllScoresAdded) {
      return;
    }
    switch (chosenDistr) {
      case DistributionType.none:
        setNone();
        break;
      case DistributionType.spreadOut:
        setSpreadOut();
        break;
      case DistributionType.proportional:
        setProportional();
        break;
      default:
        setNone();
    }
  }
}
