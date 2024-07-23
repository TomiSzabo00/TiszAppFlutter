import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/views/ordering/voting_screen.dart';

class OrderingSummaryScreen extends StatefulWidget {
  const OrderingSummaryScreen({super.key});

  @override
  OrderingSummaryScreenState createState() => OrderingSummaryScreenState();
}

class OrderingSummaryScreenState extends State<OrderingSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Szavazás"),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.format_line_spacing_rounded), text: "Lineáris"),
              Tab(icon: Icon(Icons.line_axis_rounded), text: "Skálázott"),
            ],
            indicatorColor: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
            labelColor: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
            unselectedLabelColor: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
          ),
        ),
        body: TabBarView(
          children: [
            VotingScreen(),
            const OrderingSummaryScreen(),
          ],
        ),
      ),
    );
  }
}
