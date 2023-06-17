import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';

class VotingViewmodel with ChangeNotifier {
  VotingState votingState = VotingState.notStarted;
  VotingViewmodel();

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<void> getVotingState() async {
    final snapshot = await ref.child('debug/firstDayOfWeek').get();
    if (snapshot.exists) {
      votingState = _getVotingStateValue(from: snapshot.value as String);
      notifyListeners();
    }
  }

  VotingState _getVotingStateValue({required String from}) {
    switch (from) {
      case "notStarted":
        return VotingState.notStarted;
      case "inProgress":
        return VotingState.inProgress;
      case "finished":
        return VotingState.finished;
      default:
        return VotingState.notStarted;
    }
  }
}
