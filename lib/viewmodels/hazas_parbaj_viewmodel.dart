import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/hazas_parbaj_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import '../helpers/try_cast.dart';
import '../services/date_service.dart';

class HazasParbajViewModel extends ChangeNotifier {
  final List<HazasParbajData> signedUpPairs = [];
  final List<HazasParbajData> votes = [];
  final List<HazasParbajData> votedAdmins = [];
  final database = DatabaseService.database;
  final name1Controller = TextEditingController();
  final name2Controller = TextEditingController();
  final teamController = TextEditingController();
  VotingState votingState = VotingState.notStarted;
  final num = TextEditingController();
  int pairsToVoteOff = 0;

  void subscribeToUserChanges() async {
    database.child('hazas_parbaj/signed_up').onChildAdded.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) => {
            if (!signedUpPairs.any((element) =>
                (element.user.uid == value.user.uid &&
                    element.name1 == value.name1 &&
                    element.name2 == value.name2 &&
                    element.team == value.team)))
              signedUpPairs.add(value),
            notifyListeners(),
          });
    });

    database.child('hazas_parbaj/votes').onChildAdded.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) => {
            if (!votes.any((element) => (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team)))
              votes.add(value),
            notifyListeners(),
          });
    });

    database.child('hazas_parbaj/signed_up').onChildRemoved.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) {
        final idx = signedUpPairs.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team));
        if (idx != -1) {
          signedUpPairs.removeAt(idx);
        }
        notifyListeners();
      });
    });

    database.child('hazas_parbaj/votes').onChildRemoved.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) {
        final idx = votes.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team));
        if (idx != -1) {
          votes.removeAt(idx);
        }
        notifyListeners();
      });
    });

    database.child('hazas_parbaj/signed_up').onChildChanged.listen((event) {
      HazasParbajData.fromSnapshot(event.snapshot).then((value) {
        final idx = signedUpPairs.indexWhere((element) =>
            (element.user.uid == value.user.uid &&
                element.name1 == value.name1 &&
                element.name2 == value.name2 &&
                element.team == value.team));
        if (idx != -1) {
          signedUpPairs[idx] = value;
        }
        notifyListeners();
      });
    });

    database
        .child('hazas_parbaj/number_of_pairs_to_vote_off')
        .onValue
        .listen((event) {
      pairsToVoteOff = tryCast<int>(event.snapshot.value) ?? 0;
      notifyListeners();
    });

    database.child('hazas_parbaj/voting_state').onValue.listen((event) {
      final state = event.snapshot.value;
      if (state == 'notStarted') {
        votingState = VotingState.notStarted;
      } else if (state == 'inProgress') {
        votingState = VotingState.inProgress;
      } else if (state == 'finished') {
        votingState = VotingState.finished;
      }
      if (state != null) {
        notifyListeners();
      }
    });
  }

  Future<bool> signUp() async {
    final key = DateService.dateInMillisAsString();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await DatabaseService.getUserData(uid);
    final data = HazasParbajData(
        user: userData,
        name1: name1Controller.text,
        name2: name2Controller.text,
        team: teamController.text);
    final index = signedUpPairs.indexWhere((element) =>
        (element.user.uid == userData.uid &&
            element.name1 == name1Controller.text &&
            element.name2 == name2Controller.text &&
            element.team == teamController.text));
    if (index != -1) {
      notifyListeners();
      return true;
    }
    final dataJson = data.toJson();
    database.child('hazas_parbaj/signed_up/$key').set(dataJson);
    signedUpPairs.add(data);
    name1Controller.clear();
    name2Controller.clear();
    teamController.clear();
    return false;
  }

  void removeFromPairs(HazasParbajData data) {
    database.child('hazas_parbaj/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        HazasParbajData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid &&
                  value.name1 == data.name1 &&
                  value.name2 == data.name2 &&
                  value.team == data.team)
                database.child('hazas_parbaj/signed_up/${e.key}').remove()
            });
      }
    });
  }

  void setNumberOfPairsToVoteOff() {
    int number = int.tryParse(num.text) ?? 0;
    database.child('hazas_parbaj/number_of_pairs_to_vote_off').set(number);
    num.clear();
  }

  void startVoting() {
    votingState = VotingState.inProgress;
    database.child('hazas_parbaj/voting_state').set('inProgress');
    notifyListeners();
  }

  void submitVote(List<HazasParbajData> data) async {
    if (votingState != VotingState.inProgress) {
      return;
    }
    int counter = 0;
    for (HazasParbajData d in data) {
      final key = FirebaseAuth.instance.currentUser!.uid;
      final dataJson = d.toJson();
      database.child('hazas_parbaj/votes/${key}_${counter++}').set(dataJson);
      votes.add(d);
    }
    notifyListeners();
  }

  void endVoting() {
    votingState = VotingState.finished;
    database.child('hazas_parbaj/voting_state').set('finished');
    notifyListeners();
  }

  void setAsVotedOut(HazasParbajData data) {
    database.child('hazas_parbaj/signed_up').once().then((event) {
      final list = event.snapshot.children.toList();
      for (DataSnapshot e in list) {
        HazasParbajData.fromSnapshot(e).then((value) => {
              if (value.user.uid == data.user.uid &&
                  value.name1 == data.name1 &&
                  value.name2 == data.name2 &&
                  value.team == data.team)
                database
                    .child('hazas_parbaj/signed_up/${e.key}/votedOut')
                    .set(true)
            });
      }
    });
  }

  String summarizeVotes() {
    final Map<HazasParbajData, int> votesMap = {};
    String result = 'A kiszavazott párok:\n';
    for (HazasParbajData data in votes) {
      if (votesMap.containsKey(data)) {
        votesMap[data] = votesMap[data]! + 1;
      } else {
        votesMap[data] = 1;
      }
    }
    final sortedVotes = votesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int count = pairsToVoteOff;
    for (MapEntry<HazasParbajData, int> entry in sortedVotes) {
      if (count == 0) {
        break;
      }
      result +=
          ('${entry.key.name1} és ${entry.key.name2} (${entry.key.team}) - ${entry.value} \n');
      count--;
      setAsVotedOut(entry.key);
    }
    votes.clear();
    database.child('hazas_parbaj/votes').remove();
    return result;
  }
}
