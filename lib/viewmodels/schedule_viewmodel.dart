import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/schedule_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

class ScheduleViewModel {
  final List<String> titleList = [
    "Hétfő",
    "Kedd",
    "Szerda",
    "Csütörtök",
    "Péntek",
    "Szombat",
    "Vasárnap"
  ];

  DatabaseReference ref = FirebaseDatabase.instance.ref();
  var firstDay = "";
  String currentTitle = "";

  Future<void> getFirstDay() async {
    final snapshot = await ref.child('debug/firstDayOfWeek').get();
    if (snapshot.exists) {
      firstDay = tryCast<String>(snapshot.value) ?? '';
      if (currentTitle.isEmpty) {
        currentTitle = firstDay;
      }
    }
  }

  Future<List<ScheduleData>> getScheduleData() async {
    await getFirstDay();
    initTitleList();
    return ApiService.getSchedule();
  }

  void initTitleList() {
    final int firstDayIndex = titleList.indexOf(firstDay);
    final List<String> temp = [];
    for (int i = firstDayIndex; i < titleList.length; i++) {
      temp.add(titleList[i]);
    }
    for (int i = 0; i < firstDayIndex; i++) {
      temp.add(titleList[i]);
    }
    titleList.clear();
    titleList.addAll(temp);
  }
}
