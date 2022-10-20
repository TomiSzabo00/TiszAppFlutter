import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tiszapp_flutter/data/schedule_data.dart';
import 'package:tiszapp_flutter/data/user_buttons.dart';

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
}
