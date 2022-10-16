import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiszapp_flutter/widgets/menu_icon.dart';
import 'package:collection/collection.dart';

class MainMenu extends StatelessWidget {
  MainMenu({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  final buttonTexts = ["Napirend", "Hírek", "Értesítések", "Beállítások"];
  final buttonIcons = [
    Icons.calendar_today,
    Icons.new_releases,
    Icons.notifications,
    Icons.settings
  ];
  final buttonActions = [
    () {
      print("txt");
    },
    () {
      print("txt");
    },
    () {
      print("txt");
    },
    () {
      print("txt");
    },
  ];
  final buttonVisible = [true, true, false, true];

  List<String> _getButtonTextsForUserRole() {
    List<String> texts = [];
    for (var i = 0; i < buttonTexts.length; i++) {
      if (buttonVisible[i]) {
        texts.add(buttonTexts[i]);
      }
    }
    return texts;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _userId() {
    return Text(user!.email ?? "No email");
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text("Sign out"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        padding: const EdgeInsets.only(top: 60),
        crossAxisCount: 2,
        children: IterableZip(
                [_getButtonTextsForUserRole(), buttonIcons, buttonActions])
            .map((btnData) {
          return MenuIcon(
            text: btnData[0] as String,
            icon: btnData[1] as IconData,
            onPressed: btnData[2] as Function(),
          );
        }).toList(),
      ),
    );
  }
}
