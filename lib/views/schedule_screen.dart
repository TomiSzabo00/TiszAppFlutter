import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/schedule_data.dart';
import 'package:tiszapp_flutter/views/schedule_info_screen.dart';
import 'package:tiszapp_flutter/services/api_service.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tcontroller;
  final List<String> titleList = [
    "Hétfő",
    "Kedd",
    "Szerda",
    "Csütörtök",
    "Péntek",
    "Szombat",
    "Vasárnap"
  ];
  String currentTitle = "";
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  var firstDay = "Csütörtök";

  @override
  void initState() {
    _tcontroller = TabController(length: 7, vsync: this);
    _tcontroller.addListener(changeTitle);
    super.initState();
  }

  Future<void> getFirstDay() async {
    final snapshot = await ref.child('debug/firstDayOfWeek').get();
    if (snapshot.exists) {
      firstDay = snapshot.value as String;
      if (currentTitle.isEmpty) {
        currentTitle = firstDay;
      }
    } else {
      print('Couldnt get first day data');
    }
  }

  Future<List<ScheduleData>> getScheduleData() async {
    getFirstDay();
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

  void changeTitle() {
    setState(() {
      currentTitle = titleList[_tcontroller.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder(
      future: getScheduleData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Hiba történt: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: CustomColor.semiTransparentWhite,
                title: Text(currentTitle),
                bottom: TabBar(
                  indicatorColor: CustomColor.btnFaceDay,
                  isScrollable: true,
                  controller: _tcontroller,
                  tabs: [
                    Tab(
                      text: titleList[0],
                    ),
                    Tab(
                      text: titleList[1],
                    ),
                    Tab(
                      text: titleList[2],
                    ),
                    Tab(
                      text: titleList[3],
                    ),
                    Tab(
                      text: titleList[4],
                    ),
                    Tab(
                      text: titleList[5],
                    ),
                    Tab(
                      text: titleList[6],
                    ),
                  ],
                ),
              ),
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: isDarkTheme
                        ? const AssetImage("images/bg2_night.png")
                        : const AssetImage("images/bg2_day.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: TabBarView(controller: _tcontroller, children: [
                  for (int i = 0; i < (snapshot.data?.length ?? 0); i++)
                    ScheduleInfoScreen(dayInfo: snapshot.data?[i]),
                ]),
              ));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Napirend betöltése..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
