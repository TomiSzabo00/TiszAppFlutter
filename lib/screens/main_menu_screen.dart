import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiszapp_flutter/services/api_service.dart';
import 'package:tiszapp_flutter/widgets/menu_icon.dart';
import 'package:collection/collection.dart';

class MainMenu extends StatelessWidget {
  MainMenu({super.key, required this.context});

  final BuildContext context;
  final User? user = FirebaseAuth.instance.currentUser;

  final buttonTexts = [
    "Napirend",
    "Pontállás",
    "Pontok feltöltése",
    "Képek",
    "Képek feltöltése",
    "Szövegek",
    "Szövegek feltöltése",
    "Daloskönyv",
    "Kijelentkezés"
  ];
  final buttonIcons = [
    Icons.calendar_today,
    Icons.format_list_numbered,
    Icons.add,
    Icons.image,
    Icons.add,
    Icons.text_fields,
    Icons.add,
    Icons.music_note,
    Icons.logout
  ];
  //final buttonVisible = [true, true, true, true, true, true, true, true, true];

  List<String> _getButtonTextsForUserRole(List<bool> buttonVisible) {
    List<String> texts = [];
    for (var i = 0; i < buttonTexts.length; i++) {
      if (buttonVisible[i]) {
        texts.add(buttonTexts[i]);
      }
    }
    return texts;
  }

  List<IconData> _getButtonIconsForUserRole(List<bool> buttonVisible) {
    List<IconData> icons = [];
    for (var i = 0; i < buttonIcons.length; i++) {
      if (buttonVisible[i]) {
        icons.add(buttonIcons[i]);
      }
    }
    return icons;
  }

  List<Function> _getButtonActionsForUserRole(List<bool> buttonVisible) {
    List<Function> actions = [];
    _getButtonTextsForUserRole(buttonVisible).forEach((element) {
      if (element == "Kijelentkezés") {
        actions.add(signOut);
      } else {}
      actions.add(() {
        _navigateToScreen(element);
      });
    });
    return actions;
  }

  void _navigateToScreen(String screenName) {
    Navigator.pushNamed(context, '/$screenName');
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _userId() {
    return Text(user!.email ?? "No email");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        body: FutureBuilder(
      future: ApiService.getButtonVisibility(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Hiba történt: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(isDarkTheme
                      ? "images/bg2_night.png"
                      : "images/bg2_day.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: GridView.count(
                padding: const EdgeInsets.only(top: 60),
                crossAxisCount: 2,
                children: IterableZip([
                  _getButtonTextsForUserRole(snapshot.data!),
                  _getButtonIconsForUserRole(snapshot.data!),
                  _getButtonActionsForUserRole(snapshot.data!),
                ]).map((btnData) {
                  return MenuIcon(
                    text: btnData[0] as String,
                    icon: btnData[1] as IconData,
                    onPressed: btnData[2] as Function(),
                  );
                }).toList(),
              ));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}
