import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class NotificationViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  List<bool> switches = List.empty(growable: true);
  bool allUsersSwitch = false;
  bool adminsSwitch = false;

  void initSwitches() {
    final database = FirebaseDatabase.instance.ref();
    database.child('number_of_teams').onValue.listen((event) {
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

  void sendNotification() {}
}
