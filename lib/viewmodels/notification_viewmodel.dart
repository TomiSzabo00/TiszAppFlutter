import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

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

  Future<void> sendNotification() async {
    startedSending = true;
    List<String> tokens = await getTokens();
    AccessCredentials credentials = await obtainCredentials();
    const url =
        "https://fcm.googleapis.com/v1/projects/tiszapp-175fb/messages:send";
    var header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${credentials.accessToken.data}"
    };
    for (final token in tokens) {
      var request = {
        "message": {
          "token": token,
          "notification": {
            "title": titleController.text,
            "body": bodyController.text,
          },
          "android": {
            "notification": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "body": bodyController.text,
            }
          },
        }
      };
      try {
        var response = await http.post(
          Uri.parse(url),
          headers: header,
          body: json.encode(request),
        );
        startedSending = false;
        if (response.statusCode == 200) {
          notifyListeners();
          if (kDebugMode) {
            print('notification sent. response: ${response.body}');
          }
        } else {
          error = response.body;
          notifyListeners();
          if (kDebugMode) {
            print('notification not sent. reason: ${response.body}');
          }
        }
      } catch (e) {
        startedSending = false;
        error = e.toString();
        notifyListeners();
        if (kDebugMode) {
          print('error: $e');
        }
        return;
      }
    }
  }

  void dismissAlert() {
    error = null;
    notifyListeners();
  }

  Future<AccessCredentials> obtainCredentials() async {
    final serviceFile = await StorageService.getServiceFile();
    var accountCredentials = ServiceAccountCredentials.fromJson(serviceFile);
    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    var client = http.Client();
    AccessCredentials credentials =
        await obtainAccessCredentialsViaServiceAccount(
            accountCredentials, scopes, client);

    client.close();
    return credentials;
  }

  Future<List<String>> getTokens() async {
    final List<String> tokens = List.empty(growable: true);
    final database = FirebaseDatabase.instance.ref();

    final event = await database.child('notification_tokens').once();
    if (event.snapshot.value == null) {
      return tokens;
    }
    // decode data
    final data = tryCast<Map>(event.snapshot.value);
    if (data == null) {
      return tokens;
    }
    data.forEach((key, value) {
      DatabaseService.getUserData(value).then((user) {
        if (user.isAdmin && adminsSwitch) {
          tokens.add(key);
        } else if (allUsersSwitch) {
          tokens.add(key);
        } else if (user.teamNum > 0 &&
            switches.length >= user.teamNum &&
            switches[user.teamNum - 1]) {
          tokens.add(key);
        }
      });
    });

    return tokens;
  }
}
