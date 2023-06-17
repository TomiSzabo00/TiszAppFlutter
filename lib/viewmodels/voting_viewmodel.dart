import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class VotingViewmodel with ChangeNotifier {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  VotingState votingState = VotingState.notStarted;
  bool isVoteSent = false;
  List<int> teams = [];

  VotingViewmodel();

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

  Future<void> getTeams() async {
    if (teams.isNotEmpty) {
      return;
    }
    final numOfTeams = await DatabaseService.getNumberOfTeams();
    for (var i = 1; i <= numOfTeams; i++) {
      teams.add(i);
    }
  }

  void _setVotingState(VotingState votingState) {
    ref.child('voting/state').set(votingState.toString().split('.').last);
  }

  void startVoting() async {
    _setVotingState(VotingState.inProgress);
    notifyListeners();
  }

  void finishVoting() {
    _setVotingState(VotingState.finished);
    notifyListeners();
  }

  void listenToVotingState() {
    ref.child('voting/state').onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        votingState = _getVotingStateValue(from: snapshot.value as String);
        notifyListeners();
      }
    });
  }

  void sendVote() {
    
  }
}
