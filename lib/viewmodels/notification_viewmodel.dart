import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  List<bool> switches = List.empty(growable: true);
  bool allUsersSwitch = false;
  bool adminsSwitch = false;
  bool startedSending = false;
  String? error;

  String get alertTitle => error == null ? 'Sikeres küldés' : 'Hiba történt';

  void initSwitches() {
    adminsSwitch = false;
    allUsersSwitch = false;
    final database = DatabaseService.database;
    database.child('_settings/number_of_teams').onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      // decode data
      final data = tryCast<int>(event.snapshot.value) ?? 4;
      switches = List.generate(data, (index) => false);
      notifyListeners();
    });
  }

  void turnOnAllUsers() {
    allUsersSwitch = true;
    for (int i = 0; i < switches.length; i++) {
      switches[i] = true;
    }
    notifyListeners();
  }

  void turnOffAllUsers() {
    allUsersSwitch = false;
    for (int i = 0; i < switches.length; i++) {
      switches[i] = false;
    }
    notifyListeners();
  }

  void turnOnAdmins() {
    adminsSwitch = true;
    notifyListeners();
  }

  void turnOffAdmins() {
    adminsSwitch = false;
    notifyListeners();
  }

  void updateSwitch(int index, bool value) {
    switches[index] = value;
    if (switches.every((element) => element == true)) {
      allUsersSwitch = true;
    } else {
      allUsersSwitch = false;
    }
    notifyListeners();
  }

  void dismissAlert() {
    error = null;
    notifyListeners();
  }

  Future<List<String>> getTokens() async {
    List<String> tokens = [];
    final allTokens = await NotificationService.getTokensAsMap();
    await Future.wait([
      for (var entry in allTokens.entries)
        DatabaseService.getUserData(entry.key).then((user) {
        if (user.isAdmin && adminsSwitch) {
          tokens.add(entry.value);
        } else if (allUsersSwitch && !user.isAdmin) {
          tokens.add(entry.value);
        } else if (user.teamNum > 0 &&
            switches.length >= user.teamNum &&
            switches[user.teamNum - 1]) {
          tokens.add(entry.value);
        }
      })
    ]);
    return tokens;
  }

  Future<void> sendNotification() async {
    startedSending = true;
    notifyListeners();
    final response = await NotificationService.sendNotification(
        await getTokens(), titleController.text, bodyController.text);
    startedSending = false;
    if (response.$1) {
      error = null;
    } else {
      error = response.$2;
    }
    notifyListeners();
  }
}
