// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/scores/score_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

enum UploadResult {
  success,
  noTeamSelected,
  limitReached,
}

class StylePointsViewModel with ChangeNotifier {
  StylePointsViewModel() {
    // initializeDateFormatting();
  }

  int numberOfTeams = 4;
  int maxNumberOfStylePoints = 1;
  bool isStylePointsPerTeam = true;
  int curTeamSelected = 0;

  Future<int> getNumberOfTeams() async {
    final num = await DatabaseService.getNumberOfTeams();
    numberOfTeams = num;
    return num;
  }

  Future<int> getMaxNumberOfStylePoints() async {
    final num = await DatabaseService.getMaxNumberOfStylePoints();
    maxNumberOfStylePoints = num;
    return num;
  }

  Future<bool> getAreStylePointsPerTeam() async {
    final snapshot = await DatabaseService.database.child('_settings/style_points_per_team').get();
    if (snapshot.exists) {
      final isPerTeam = tryCast<bool>(snapshot.value) ?? true;
      isStylePointsPerTeam = isPerTeam;
      return isPerTeam;
    }
    return true;
  }

  Future<Map<String, Score>> getUploadedStylePoints() async {
    final scoresRef = DatabaseService.database.child("scores");
    final snapshot = await scoresRef.once();
    final scores = snapshot.snapshot.children;

    List<MapEntry<String, Score>> stylePoints = [];

    scores.forEach((scoreSnapshot) {
      final score = Score.fromSnapshot(scoreSnapshot as DataSnapshot);
      final date = scoreSnapshot.key!;
      if (score.name.startsWith('SP: ')) {
        stylePoints.add(MapEntry<String, Score>(date, score));
      }
    });

    return Map.fromEntries(stylePoints);
  }

  Future<bool> hasUserReachedLimit() async {
    final scores = await getUploadedStylePoints();
    final allScoresByUser = Map.of(scores)
      ..removeWhere((key, value) => value.author != FirebaseAuth.instance.currentUser!.uid);

    final uploadedToday = allScoresByUser.entries.where((entry) {
      final now = DateTime.now();
      final formatter = DateFormat('yyyyMMdd');
      final today = formatter.format(now);
      final date = entry.key.substring(0, 8);
      bool isToday = today == date;
      if (isStylePointsPerTeam) {
        return isToday && entry.value.scores.indexWhere((element) => element == 1) == curTeamSelected;
      } else {
        return isToday;
      }
    });

    return uploadedToday.length >= maxNumberOfStylePoints;
  }

  Future<UploadResult> uploadScore() async {
    if (curTeamSelected == -1) {
      return UploadResult.noTeamSelected;
    }

    if (await hasUserReachedLimit()) {
      return UploadResult.limitReached;
    }

    var scores = List.generate(numberOfTeams, (index) {
      if (index == curTeamSelected) {
        return 1;
      } else {
        return 0;
      }
    });
    final user = await DatabaseService.getUserData(FirebaseAuth.instance.currentUser!.uid);
    final name = 'SP: ${user.name}';
    var score = Score(author: FirebaseAuth.instance.currentUser!.uid, name: name, scores: scores);

    var ref = DatabaseService.database.child("scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());

    curTeamSelected = -1;
    notifyListeners();

    return UploadResult.success;
  }
}
