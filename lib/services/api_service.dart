import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tiszapp_flutter/models/admin_api_data.dart';
import 'package:tiszapp_flutter/models/schedule_data.dart';
import 'package:tiszapp_flutter/models/user_api_data.dart';
import 'package:tiszapp_flutter/models/user_buttons.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

class ApiService {
  static const String apiURL =
      'https://opensheet.elk.sh/10JPtOuuQAMpGmorEHFW_yU-M2M99AAhpZn09CRcGPK4';

  static Future<List<bool>> getButtonVisibility() async {
    final response =
        await http.Client().get(Uri.parse('$apiURL/user_menu_debug'));

    return compute(_parseButtonVisibility, response.body);
  }

  static List<bool> _parseButtonVisibility(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    final List<UserButtons> parsedButtons =
        parsed.map<UserButtons>((json) => UserButtons.fromJson(json)).toList();

    List<bool> buttonVisibility = [];

    for (var element in parsedButtons) {
      if (element.visible == "1") {
        buttonVisibility.add(true);
      } else {
        buttonVisibility.add(false);
      }
    }
    return buttonVisibility;
  }

  static Future<List<ScheduleData>> getSchedule() async {
    final response = await http.Client().get(Uri.parse('$apiURL/schedule'));
    final encodedData = const Utf8Decoder().convert(response.bodyBytes);

    return compute(_parseSchedule, encodedData);
  }

  static List<ScheduleData> _parseSchedule(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed
        .map<ScheduleData>((json) => ScheduleData.fromJson(json))
        .toList();
  }

  static Future<List<String>> getNames() async {
    final responseUser = await http.Client().get(Uri.parse('$apiURL/users'));
    final encodedUserData = const Utf8Decoder().convert(responseUser.bodyBytes);

    final responseAdmin = await http.Client().get(Uri.parse('$apiURL/admins'));
    final encodedAdminData =
        const Utf8Decoder().convert(responseAdmin.bodyBytes);

    final users = compute(_parseUserNames, encodedUserData);
    final admins = compute(_parseAdminNames, encodedAdminData);

    return Future.wait([users, admins]).then((value) {
      return value[0] + value[1];
    });
  }

  static List<String> _parseUserNames(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    final List<UserApiData> parsedNames =
        parsed.map<UserApiData>((json) => UserApiData.fromJson(json)).toList();

    List<String> names = [];

    for (var element in parsedNames) {
      names.add(element.name);
    }
    return names;
  }

  static List<String> _parseAdminNames(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    final List<AdminApiData> parsedNames = parsed
        .map<AdminApiData>((json) => AdminApiData.fromJson(json))
        .toList();

    List<String> names = [];

    for (var element in parsedNames) {
      names.add(element.name);
    }
    return names;
  }

  static Future<List<AdminApiData>> getAvailableUsers() async {
    final responseUser = await http.Client().get(Uri.parse('$apiURL/users'));
    final encodedUserData = const Utf8Decoder().convert(responseUser.bodyBytes);

    final responseAdmin = await http.Client().get(Uri.parse('$apiURL/admins'));
    final encodedAdminData =
        const Utf8Decoder().convert(responseAdmin.bodyBytes);

    final availableUsers = compute(_parseAvailableUsers, encodedUserData);
    final availableAdmins = compute(_parseAvailableUsers, encodedAdminData);

    return Future.wait([availableUsers, availableAdmins]).then((value) {
      return value[0] + value[1];
    });
  }

  static List<AdminApiData> _parseAvailableUsers(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed
        .map<AdminApiData>((json) => AdminApiData.fromJson(json))
        .toList();
  }

  static Future<List<UserData>> getUserInfos() async {
    final responseUser = await http.Client().get(Uri.parse('$apiURL/users'));
    Map encodedUserData = {};
    encodedUserData['data'] =
        const Utf8Decoder().convert(responseUser.bodyBytes);
    encodedUserData['isAdmin'] = false;

    final responseAdmin = await http.Client().get(Uri.parse('$apiURL/admins'));
    Map encodedAdminData = {};
    encodedAdminData['data'] =
        const Utf8Decoder().convert(responseAdmin.bodyBytes);
    encodedAdminData['isAdmin'] = true;

    final availableUsers = compute(_parseUsers, encodedUserData);
    final availableAdmins = compute(_parseUsers, encodedAdminData);

    return Future.wait([availableUsers, availableAdmins]).then((value) {
      return value[0] + value[1];
    });
  }

  static List<UserData> _parseUsers(Map response) {
    final responseBody = response['data'];
    final isAdmin = response['isAdmin'];
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    if (isAdmin) {
      return parsed
          .map<AdminApiData>((json) => AdminApiData.fromJson(json))
          .map<UserData>((adminData) => UserData(
              uid: "",
              name: adminData.name,
              isAdmin: true,
              teamNum: 0,
              profilePictureUrl: ''))
          .toList();
    } else {
      return parsed
          .map<UserApiData>((json) => UserApiData.fromJson(json))
          .map<UserData>((userData) {
        final parsedTeamNum = int.tryParse(userData.teamNum);
        if (parsedTeamNum == null) {
          debugPrint(
              "Hibás teamNum érték: '${userData.teamNum}' a felhasználónál '${userData.name}'");
        }
        return UserData(
          uid: "",
          name: userData.name,
          isAdmin: false,
          teamNum: parsedTeamNum ?? 5,
          profilePictureUrl: '',
        );
      }).toList();
    }
  }
}
