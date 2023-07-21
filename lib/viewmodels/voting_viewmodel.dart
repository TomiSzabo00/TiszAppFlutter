import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/date_service.dart';


class VotingViewmodel with ChangeNotifier {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  VotingState votingState = VotingState.notStarted;
  bool isVoteSent = false;
  List<int> teams = [];

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
        teams.clear();
        votingState = _getVotingStateValue(from: tryCast<String>(snapshot.value) ?? '');
        notifyListeners();
      }
    });
  }

  void sendVote() async {
    final key = DateService.dateInMillisAsString();
    final numOfTeams = await DatabaseService.getNumberOfTeams();

    Map<int, int> votes = {};

    for (var i = 1; i <= numOfTeams; i++) {
      var score = teams.indexOf(i);
      votes[i] = score;
    }

    ref.child('voting/votes/$key').set(votes);
    isVoteSent = true;
    notifyListeners();
  }

  void resetVote() {
    isVoteSent = false;
    teams.clear();
    notifyListeners();
  }

  void endVote() {
    _setVotingState(VotingState.finished);
    notifyListeners();
  }

  void closeVote() {
    _setVotingState(VotingState.notStarted);
    _removeVotes();
    notifyListeners();
  }

  void _removeVotes() {
    isVoteSent = false;
    ref.child('voting/votes').remove();
  }

  Future<Map<int, String>> getVotingResults() async {
    final numOfTeams = await DatabaseService.getNumberOfTeams();
    List<int> results = List.generate(numOfTeams, (_) => 0);

    await ref.child('voting/votes').get().then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic> votesWithTimeStamps =
            tryCast<Map<dynamic, dynamic>>(snapshot.value) ?? {};
        votesWithTimeStamps.forEach((timestamp, list) {
          List<int> votes = list.whereType<int>().toList();
          for (var i = 0; i < numOfTeams; i++) {
            results[i] += votes[i];
          }
        });
      }
    });

    final Map<int, int> resultsMap = {};
    for (var i = 0; i < numOfTeams; i++) {
      resultsMap[i + 1] = results[i];
    }

    // merge into new map if the values are the same
    final Map<int, List<int>> mergedResults = {};
    resultsMap.forEach((key, value) {
      if (!mergedResults.containsKey(value)) {
        mergedResults[value] = [key];
      } else {
        mergedResults[value]!.add(key);
      }
    });

    // sort by key
    final sortedResults = SplayTreeMap<int, List<int>>.from(mergedResults);

    // replace values with team names
    final Map<int, String> resultsWithTeamNames = {};
    for (var j = 0; j < sortedResults.length; j++) {
      final key = sortedResults.keys.elementAt(j);
      for (var i = 0; i < sortedResults[key]!.length; i++) {
        final teamName = '${sortedResults[key]!.elementAt(i)}. csapat';
        if (resultsWithTeamNames[j] == null) {
          resultsWithTeamNames[j] = teamName;
        } else {
          resultsWithTeamNames[j] = '${resultsWithTeamNames[j]}, $teamName';
        }
      }
    }

    return resultsWithTeamNames;
  }
}
