import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<Map<String, String>> getTokensAsMap() async {
    final database = FirebaseDatabase.instance.ref();

    final event = await database.child('notification_tokens').once();
    if (event.snapshot.value == null) {
      return {};
    }

    final data = tryCast<Map>(event.snapshot.value) ?? {};
    return data.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  static Future<AccessCredentials> obtainCredentials() async {
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

  static Future<(bool, String)> sendNotification(List<String> tokens, String title, String body) async {
    AccessCredentials credentials = await NotificationService.obtainCredentials();
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
            "title": title,
            "body": body,
          },
          "android": {
            "notification": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "body": body,
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
        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('notification sent. response: ${response.body}');
          }
          return (true, '');
        } else {
          if (kDebugMode) {
            print('notification not sent. reason: ${response.body}');
          }
          return (false, response.body);
        }
      } catch (e) {
        if (kDebugMode) {
          print('error: $e');
        }
        return (false, e.toString());
      }
    }
    return (false, 'NO RESPONSE');
  }
}
