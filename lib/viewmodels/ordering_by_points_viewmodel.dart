import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class OrderingByPointsViewModel extends ChangeNotifier {
  final nodeName = 'ordering_by_points';
  final database = DatabaseService.database;
  int maxPoints = 10;
  TextEditingController maxController = TextEditingController();
  int numberOfTeams = 4;
  List<TextEditingController> scoreControllers = [];

  void getNumberOfTeams() async {
    DatabaseService.getNumberOfTeams().then((value) {
      numberOfTeams = value;
      scoreControllers = List.generate(value, (_) => TextEditingController());
      notifyListeners();
    });
  }

  void subscribeToMaxPointChanges() {
    database.child('$nodeName/max_points').onValue.listen((event) {
      final max = tryCast<int>(event.snapshot.value);
      if (max != null) {
        maxPoints = max;
        notifyListeners();
      }
    });
  }

  Stream<VotingState> votingStateStream() async* {
    yield* database.child('$nodeName/state').onValue.map<VotingState>((event) {
      final state = tryCast<String>(event.snapshot.value);
      if (state != null) {
        return VotingState.values.firstWhere(
          (element) => element.toString() == 'VotingState.$state',
          orElse: () => VotingState.notStarted,
        );
      }
      return VotingState.notStarted;
    });
  }

  void _setVotingState(VotingState state) {
    database.child('$nodeName/state').set(state.toString().split('.').last);
  }

  void _setMaxPoints() {
    final max = int.tryParse(maxController.text);
    if (max != null) {
      database.child('$nodeName/max_points').set(max);
    } else {
      database.child('$nodeName/max_points').set(10);
    }
  }

  void startVoting() {
    _setMaxPoints();
    _setVotingState(VotingState.inProgress);
  }

  void scoreChanged(int index, String score) {
    final scoreInt = int.tryParse(score) ?? 1;
    if (scoreInt > maxPoints) {
      scoreControllers[index].text = maxPoints.toString();
    }
  }

  bool uploadScores() {
    if (scoreControllers.any((element) => int.tryParse(element.text) == null)) {
      return false;
    }
    final scores = scoreControllers.map((e) => int.tryParse(e.text) ?? 0).toList();
    if (scores.any((element) => element < 1)) {
      return false;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    database.child('$nodeName/scores/$uid').set(scores);
    return true;
  }

  Stream<bool> didUserUploadScores() async* {
    yield* database.child('$nodeName/scores/${FirebaseAuth.instance.currentUser?.uid}').onValue.map<bool>((DatabaseEvent event) {
      return event.snapshot.exists;
    });
  }

  void finishVoting() {
    _setVotingState(VotingState.finished);
    for (var element in scoreControllers) {
      element.clear();
    }
  }
}
