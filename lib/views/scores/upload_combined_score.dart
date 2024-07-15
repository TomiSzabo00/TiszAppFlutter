import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/views/scores/upload_ocsi_score_screen.dart';
import 'package:tiszapp_flutter/views/scores/upload_score_screen.dart';
import 'package:tiszapp_flutter/views/scores/upload_style_point_screen.dart';

class UploadCombinedScoreScreen extends StatefulWidget {
  const UploadCombinedScoreScreen({super.key});

  @override
  UploadCombinedScoreScreenState createState() => UploadCombinedScoreScreenState();
}

class UploadCombinedScoreScreenState extends State<UploadCombinedScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pontozás"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Sima"),
              Tab(text: "Öcsi"),
              Tab(text: "Stíluspont"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UploadScoreScreen(),
            UploadOcsiScoreScreen(),
            UploadStylePointScreen(),
          ],
        ),
      ),
    );
  }
}
