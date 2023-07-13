import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  List<bool> switches = List.empty(growable: true);
  bool allUsersSwitch = false;
  bool adminsSwitch = false;

  static const platform = MethodChannel('flutter/notifications');
  bool? didSend;
  String? error;

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

  void sendNotification() async {
    List<String> tokens = await getTokens();
    String serverKey = await getServerKey();
    try {
      final bool result = await platform.invokeMethod('sendNotification', {
        'title': titleController.text,
        'body': bodyController.text,
        'to': tokens,
        'serverKey': serverKey
      });
      print(result);
      didSend = result;
      notifyListeners();
    } on PlatformException catch (e) {
      didSend = false;
      error = e.message;
      notifyListeners();
    }
  }

  Future<List<String>> getTokens() async {
    final List<String> tokens = List.empty(growable: true);
    final database = FirebaseDatabase.instance.ref();

    final event = await database.child('notification_tokens').once();
    if (event.snapshot.value == null) {
      return tokens;
    }
    // decode data
    final data = tryCast<Map<String, String>>(event.snapshot.value);
    if (data == null) {
      return tokens;
    }
    data.forEach((key, value) {
      DatabaseService.getUserData(key).then((user) {
        if (user.isAdmin && adminsSwitch) {
          tokens.add(value);
        } else if (allUsersSwitch) {
          tokens.add(value);
        } else if (user.teamNum > 0 &&
            switches.length <= user.teamNum &&
            switches[user.teamNum - 1]) {
          tokens.add(value);
        }
      });
    });

    return tokens;
  }

  Future<String> getServerKey() async {
    final database = FirebaseDatabase.instance.ref();
    final event = await database.child('messagingKey/key').once();
    if (event.snapshot.value == null) {
      return '';
    }
    // decode data
    final data = tryCast<String>(event.snapshot.value);
    if (data == null) {
      return '';
    }
    return data;
  }
}
