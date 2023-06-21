import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class QuizViewModel extends ChangeNotifier {
  var state = QuizState.disabled;

  bool get canSend => state == QuizState.enabled;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final List<int> signals = [];
  int numberOfTeams = 4;

  QuizViewModel() {
    initializeDateFormatting();
  }

  void _updateState(QuizState newState) {
    state = newState;
    notifyListeners();
  }

  void subscribeToQuizStateChanges() {
    // read data from firebase
    DatabaseReference database = FirebaseDatabase.instance.ref();
    database.child('quiz/state').onValue.listen((event) {
      if (event.snapshot.value == null) {
        _updateState(QuizState.disabled);
        return;
      }
      // decode data
      final data = event.snapshot.value as String;
      final newState = _decodeQuizState(data);
      // update state
      _updateState(newState);
    });
  }

  void subscribeToSignalEvents() async {
    database.child('quiz/signals').onChildAdded.listen((event) {
      if (event.snapshot.value == null) {
        _updateState(QuizState.disabled);
        return;
      }
      // decode data
      final senderUid = event.snapshot.value as String;
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (senderUid == uid) {
        _updateState(QuizState.didSend);
        return;
      }

      DatabaseService.getUserData(uid).then((currData) {
        final currTeamNum = currData.teamNum;
        DatabaseService.getUserData(senderUid).then((otherData) {
          final otherTeamNum = otherData.teamNum;
          if (currTeamNum == otherTeamNum) {
            _updateState(QuizState.teammateDidSend);
            return;
          }
        });
      });
    });

    database.child('quiz/signals').onChildRemoved.listen((event) {
      if (event.snapshot.value == null || state == QuizState.disabled) {
        _updateState(QuizState.disabled);
        return;
      }
      // decode data
      final senderUid = event.snapshot.value as String;
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (senderUid == uid) {
        _updateState(QuizState.enabled);
        return;
      }

      DatabaseService.getUserData(uid).then((currData) {
        final currTeamNum = currData.teamNum;
        DatabaseService.getUserData(senderUid).then((otherData) {
          final otherTeamNum = otherData.teamNum;
          if (currTeamNum == otherTeamNum) {
            _updateState(QuizState.enabled);
            return;
          }
        });
      });
    });
  }

  QuizState _decodeQuizState(String data) {
    switch (data) {
      case 'enabled':
        return QuizState.enabled;
      case 'disabled':
        return QuizState.disabled;
      default:
        return QuizState.disabled;
    }
  }

  void send() {
    _updateState(QuizState.didSend);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    database.child('quiz/signals/${_getDateAsString()}').set(uid);
  }

  String _getDateAsString() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    return formatter.format(now);
  }

  void disable() {
    database.child('quiz/state').set('disabled');
    _deleteSignals();
  }

  void reset() {
    _deleteSignals();
    _enable();
  }

  void _deleteSignals() {
    database.child('quiz/signals').remove();
  }

  void _enable() {
    database.child('quiz/state').set('enabled');
  }

  void _clearSignals() {
    signals.clear();
  }

  void subscribeToSignalEventsAsAdmin() async {
    database.child('quiz/signals').onChildAdded.listen((event) {
      if (event.snapshot.value == null) {
        _clearSignals();
        notifyListeners();
        return;
      }
      // decode data
      final senderUid = event.snapshot.value as String;
      DatabaseService.getUserData(senderUid).then((senderData) {
        // check if this team already sent a signal
        if (signals.contains(senderData.teamNum) ||
            signals.length >= numberOfTeams) {
          return;
        }
        signals.add(senderData.teamNum);
        notifyListeners();
      });
    });

    database.child('quiz/signals').onChildRemoved.listen((event) {
      // decode data
      final senderUid = event.snapshot.value as String;
      DatabaseService.getUserData(senderUid).then((senderData) {
        // check if this team already sent a signal
        if (signals.contains(senderData.teamNum)) {
          signals.remove(senderData.teamNum);
          notifyListeners();
        }
      });
    });
  }

  void setNumberOfTeams() {
    database.child('number_of_teams').onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      // decode data
      final data = event.snapshot.value as int;
      numberOfTeams = data;
      notifyListeners();
    });
  }

  int? getTeamNum(int index) {
    if (signals.length <= index) {
      return null;
    }
    return signals[index];
  }
}
