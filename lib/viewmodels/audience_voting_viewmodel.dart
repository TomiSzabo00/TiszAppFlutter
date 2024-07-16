import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/audience_voting_state.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class AudienceVotingViewModel extends ChangeNotifier {
  final DatabaseReference database = DatabaseService.database;
  final databaseNode = 'audience_votes';
  String selectedOption = '';
  Map<String, int> results = {};
  AudienceVotingState votingState = AudienceVotingState.stopped;

  TextEditingController newPairTextController = TextEditingController();

  Stream<bool> isVotingOpen() async* {
    yield* database.child('$databaseNode/voting_state').onValue.map((event) {
      final state = tryCast<String>(event.snapshot.value) ?? '';
      final stateEnum = RawValuesExtension.fromRawValue(state);
      votingState = stateEnum;
      return stateEnum == AudienceVotingState.voting || stateEnum == AudienceVotingState.paused;
    });
  }

  Stream<AudienceVotingState> getVotingState() async* {
    yield* database.child('$databaseNode/voting_state').onValue.map((event) {
      final state = tryCast<String>(event.snapshot.value) ?? '';
      return RawValuesExtension.fromRawValue(state);
    });
  }

  Stream<bool> didUserVote() async* {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      yield true;
    }

    yield* database.child('$databaseNode/votes/$uid').onValue.map((event) {
      return event.snapshot.exists;
    });
  }

  Stream<bool> isResultVisible() async* {
    yield* database.child('$databaseNode/result_showing').onValue.map((event) {
      return tryCast<bool>(event.snapshot.value) ?? false;
    });
  }

  Stream<List<String>> getVotingOptions() async* {
    yield* database.child('$databaseNode/voting_options').onValue.map((event) {
      final rawOptions = event.snapshot.value;
      if (rawOptions != null && rawOptions is Map && rawOptions.isNotEmpty) {
        final options = rawOptions.values.cast<String>().toList();
        return options.cast<String>().toList()..sort();
      }
      return [];
    });
  }

  void selectOption(String option) {
    selectedOption = option;
    notifyListeners();
  }

  bool vote() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || selectedOption.isEmpty || votingState != AudienceVotingState.voting) {
      return false;
    }

    database.child('$databaseNode/votes/$uid').set(selectedOption);
    return true;
  }

  void subscribeToResults() {
    database.child('$databaseNode/votes').onValue.listen((event) {
      results.clear();
      if (event.snapshot.value == null) {
        return;
      }
      final votes = tryCast<Map>(event.snapshot.value) ?? {};
      if (votes.isEmpty) {
        return;
      }
      for (var element in votes.entries) {
        final option = element.value;
        results.update(option, (value) => value + 1, ifAbsent: () => 1);
      }
      results = Map.fromEntries(results.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
      notifyListeners();
    });
  }

  String getWinner() {
    if (results.isEmpty) {
      return '-';
    }
    final winner = results.entries.first;
    return winner.key;
  }

  void setVotingState(AudienceVotingState state) {
    database.child('$databaseNode/voting_state').set(state.rawValue);
  }

  void deleteVotes() {
    database.child('$databaseNode/votes').remove();
  }

  void deleteVotingOption(String option) {
    database.child('$databaseNode/voting_options').orderByValue().equalTo(option).once().then((event) {
      if (event.snapshot.value == null) {
        return;
      }
      final key = event.snapshot.children.first.key;
      database.child('$databaseNode/voting_options/$key').remove();
    });
  }

  void addVotingOption() {
    final option = newPairTextController.text;
    if (option.isEmpty) {
      return;
    }
    database.child('$databaseNode/voting_options').push().set(option);
    newPairTextController.clear();
  }

  void setResultVisibility(bool visible) {
    database.child('$databaseNode/result_showing').set(visible);
  }
}
