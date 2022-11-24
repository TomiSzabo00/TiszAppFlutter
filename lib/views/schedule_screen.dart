import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/schedule_viewmodel.dart';
import 'package:tiszapp_flutter/views/schedule_info_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tcontroller;
  final ScheduleViewModel _viewModel = ScheduleViewModel();

  @override
  void initState() {
    _tcontroller = TabController(length: 7, vsync: this);
    _tcontroller.addListener(changeTitle);
    super.initState();
  }

  void changeTitle() {
    setState(() {
      _viewModel.currentTitle = _viewModel.titleList[_tcontroller.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder(
      future: _viewModel.getScheduleData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: CustomColor.semiTransparentWhite,
                title: Text(_viewModel.currentTitle),
                bottom: TabBar(
                  indicatorColor: CustomColor.btnFaceDay,
                  isScrollable: true,
                  controller: _tcontroller,
                  tabs: [
                    Tab(
                      text: _viewModel.titleList[0],
                    ),
                    Tab(
                      text: _viewModel.titleList[1],
                    ),
                    Tab(
                      text: _viewModel.titleList[2],
                    ),
                    Tab(
                      text: _viewModel.titleList[3],
                    ),
                    Tab(
                      text: _viewModel.titleList[4],
                    ),
                    Tab(
                      text: _viewModel.titleList[5],
                    ),
                    Tab(
                      text: _viewModel.titleList[6],
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
