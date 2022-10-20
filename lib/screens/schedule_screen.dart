import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/screens/schedule_info_screen.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

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
  final firstDay = "Csütörtök";

  @override
  void initState() {
    initTitleList();
    currentTitle = titleList[0];
    _tcontroller = TabController(length: 7, vsync: this);
    _tcontroller.addListener(changeTitle);
    super.initState();
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
    return FutureBuilder(
      future: ApiService.getSchedule(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Hiba történt: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(currentTitle),
              bottom: TabBar(
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
            body: TabBarView(controller: _tcontroller, children: [
              for (int i = 0; i < (snapshot.data?.length ?? 0); i++)
                ScheduleInfoScreen(
                  dayInfo: snapshot.data?[i],
                ),
            ]),
          );
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
