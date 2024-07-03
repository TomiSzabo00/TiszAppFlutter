// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tiszapp_flutter/models/scores/score_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class OcsiScoresViewModel with ChangeNotifier {
  OcsiScoresViewModel() {
    initializeDateFormatting();
  }

  int numberOfTeams = 4;
  int curTeamSelected = 0;
  int curSliderValue = 0;
  final nameController = TextEditingController();

  Future<int> getNumberOfTeams() async {
    final num = await DatabaseService.getNumberOfTeams();
    notifyListeners();
    numberOfTeams = num;
    return num;
  }

  void uploadScore() {
    var scores = List.generate(numberOfTeams, (index) {
      if (index == curTeamSelected) {
        return curSliderValue;
      } else {
        return 0;
      }
    });
    var score = Score(
        author: FirebaseAuth.instance.currentUser!.uid,
        name: nameController.text,
        scores: scores);

    var ref = DatabaseService.database.child("scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());
  }
}
