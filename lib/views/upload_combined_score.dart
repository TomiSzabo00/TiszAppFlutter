import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/views/upload_ocsi_score_screen.dart';
import 'package:tiszapp_flutter/views/upload_score_screen.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UploadCombinedScoreScreen extends StatefulWidget {
  const UploadCombinedScoreScreen({super.key});

  @override
  UploadCombinedScoreScreenState createState() =>
      UploadCombinedScoreScreenState();
}

class UploadCombinedScoreScreenState extends State<UploadCombinedScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pontozás"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Rendes pont"),
              Tab(text: "Öcsi pont"),
              Tab(text: "Stíílus pont"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UploadScoreScreen(), // Replace with your second screen widget
            UploadOcsiScoreScreen(),
            UploadOcsiScoreScreen(),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    AnimationController? localAnimationController;
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: "Feltöltve!",
        textScaleFactor: 1.3,
      ),
      onAnimationControllerInit: (controller) =>
          localAnimationController = controller,
      displayDuration: const Duration(seconds: 2),
      dismissType: DismissType.onSwipe,
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }
}
