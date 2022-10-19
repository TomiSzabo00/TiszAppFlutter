import 'package:flutter/material.dart';

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
      body: TabBarView(
        controller: _tcontroller,
        children: [
          Center(
            child: Text(titleList[0]),
          ),
          Center(
            child: Text(titleList[1]),
          ),
          Center(
            child: Text(titleList[2]),
          ),
          Center(
            child: Text(titleList[3]),
          ),
          Center(
            child: Text(titleList[4]),
          ),
          Center(
            child: Text(titleList[5]),
          ),
          Center(
            child: Text(titleList[6]),
          ),
        ],
      ),
    );
  }
}
