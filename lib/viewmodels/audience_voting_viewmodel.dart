import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class AudienceVotingViewModel extends ChangeNotifier {
  final DatabaseReference database = DatabaseService.database;
  final databaseNode = 'audience_votes';
  String selectedOption = '';
  Map<String, int> results = {};

  Stream<bool> isVotingOpen() async* {
    yield* database.child('$databaseNode/voting_state').onValue.map((event) {
      return tryCast<bool>(event.snapshot.value) ?? false;
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
        return rawOptions.values.cast<String>().toList();
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
    if (uid == null || selectedOption.isEmpty) {
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
}
