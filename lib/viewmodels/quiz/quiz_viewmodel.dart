import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/quiz/quiz_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class QuizViewModel extends ChangeNotifier {
  var state = QuizState.disabled;

  bool get canSend => state == QuizState.enabled;
  final DatabaseReference database = DatabaseService.database;
  final List<Map<String, int>> signals = [];
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
    DatabaseReference database = DatabaseService.database;
    database.child('quiz/state').onValue.listen((event) {
      if (event.snapshot.value == null) {
        _updateState(QuizState.disabled);
        return;
      }
      // decode data
      final data = tryCast<String>(event.snapshot.value) ?? '';
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
      final senderUid = tryCast<String>(event.snapshot.value) ?? '';
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (senderUid == uid || state == QuizState.didSend) {
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
      final senderUid = tryCast<String>(event.snapshot.value) ?? '';
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
    notifyListeners();
  }

  void subscribeToSignalEventsAsAdmin() async {
    database.child('quiz/signals').onValue.listen((event) async {
      _clearSignals();
      if (event.snapshot.value == null) {
        return;
      }

      final data = tryCast<Map>(event.snapshot.value) ?? {};
      final signalDatas = data.entries.map((entry) => {entry.key: entry.value}).toList();
      debugPrint('signalDatas: $signalDatas');
      for (var signal in signalDatas) {
        final userData = await DatabaseService.getUserData(signal.values.first);
        if (signals.any((element) => element.containsValue(userData.teamNum))) {
          continue;
        }

        signals.add({signal.keys.first: userData.teamNum});
        signals.sort((a, b) => a.keys.first.compareTo(b.keys.first));
        notifyListeners();
      }
    });
  }

  void setNumberOfTeams() {
    database.child('_settings/number_of_teams').onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      // decode data
      final data = tryCast<int>(event.snapshot.value) ?? 4;
      numberOfTeams = data;
      notifyListeners();
    });
  }

  int? getTeamNum(int index) {
    if (signals.length <= index) {
      return null;
    }
    return signals[index].values.first;
  }

  String? timeDiffernceFromPrevious({required int index}) {
    final timeDifference = _getTimeDifference(index);
    if (timeDifference == null) {
      return null;
    }
    final minutes = (timeDifference / 60000).floor();
    final seconds = ((timeDifference % 60000) / 1000).floor();
    final milliseconds = (timeDifference % 1000).floor();

    var minutesString = minutes.toString().padLeft(2, '0');
    var secondsString = seconds.toString().padLeft(2, '0');
    var millisecondsString = milliseconds.toString().padLeft(3, '0');

    // if (minutes == 0) {
    //   return '+$secondsString.$millisecondsString';
    // } else {
    return '+$minutesString:$secondsString.$millisecondsString';
    // }
  }

  int? _getTimeDifference(int index) {
    if (index == 0 || signals.length <= index) {
      return null;
    }
    final prevDate = _convertStringToDate(signals[index - 1].keys.first);
    final date = _convertStringToDate(signals[index].keys.first);
    return date.difference(prevDate).inMilliseconds;
  }

  DateTime _convertStringToDate(String data) {
    final year = int.parse(data.substring(0, 4));
    final month = int.parse(data.substring(4, 6));
    final day = int.parse(data.substring(6, 8));
    final hour = int.parse(data.substring(8, 10));
    final minute = int.parse(data.substring(10, 12));
    final second = int.parse(data.substring(12, 14));
    final millisecond = int.parse(data.substring(14, 17));
    return DateTime(year, month, day, hour, minute, second, millisecond);
  }
}
