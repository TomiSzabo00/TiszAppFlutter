import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/models/score_data.dart';

class ScoresViewModel {
  List<Score> scores = [];

  Future<void> getScores() async {
    final scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      scores.insert(0, Score.fromSnapshot(event.snapshot));
    });
  }
}
