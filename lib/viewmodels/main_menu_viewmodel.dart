import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

class MainMenuViewModel {
  MainMenuViewModel(BuildContext context) {
    _context = context;
  }

  late BuildContext _context;
  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);

  final buttonTexts = [
    "Napirend",
    "Pontállás",
    "Pontok feltöltése",
    "Képek",
    "Képek feltöltése",
    "Szövegek",
    "Szövegek feltöltése",
    "Daloskönyv",
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
  ];

  List<String> getButtonTextsForUserRole(List<bool> buttonVisible) {
    List<String> texts = [];
    for (var i = 0; i < buttonTexts.length; i++) {
      if (buttonVisible[i]) {
        texts.add(buttonTexts[i]);
      }
    }
    return texts;
  }

  List<IconData> getButtonIconsForUserRole(List<bool> buttonVisible) {
    List<IconData> icons = [];
    for (var i = 0; i < buttonIcons.length; i++) {
      if (buttonVisible[i]) {
        icons.add(buttonIcons[i]);
      }
    }
    return icons;
  }

  List<Function> getButtonActionsForUserRole(List<bool> buttonVisible) {
    List<Function> actions = [];
    getButtonTextsForUserRole(buttonVisible).forEach((element) {
      if (element == "Kijelentkezés") {
        actions.add(_signOut);
      } else {}
      actions.add(() {
        _navigateToScreen(element);
      });
    });
    return actions;
  }

  void _navigateToScreen(String screenName) {
    Navigator.pushNamed(_context, '/$screenName');
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> getUserData() async {
    return await FirebaseDatabase.instance
        .ref()
        .child('users/${FirebaseAuth.instance.currentUser?.uid}')
        .get()
        .then((snapshot) {
      if (snapshot.value != null) {
        user = UserData.fromSnapshot(snapshot);
        return user.name;
      } else {
        return null;
      }
    });
  }

  Future<List<bool>> getButtonVisibility() async {
    return ApiService.getButtonVisibility();
  }
}
