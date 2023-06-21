import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

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
    "Szavazás",
    "Wordle",
    "AV Kvíz"
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
    Icons.how_to_vote,
    Icons.type_specimen,
    Icons.front_hand,
  ];

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
      if (element == "AV Kvíz") {
        actions.add(() {
          _navigateToScreen(element, arguments: user.isAdmin);
        });
      } else {
        actions.add(() {
          _navigateToScreen(element);
        });
      }
    });
    return actions;
  }

  void _navigateToScreen(String screenName, {Object? arguments}) {
    Navigator.pushNamed(_context, '/$screenName', arguments: arguments);
  }

  Future<IterableZip<Object>> getButtons() async {
    List<bool> visibility = [];
    final apiResponse = await ApiService.getButtonVisibility();
    user = await DatabaseService.getUserData(
        FirebaseAuth.instance.currentUser!.uid);
    if (user.isAdmin) {
      visibility = apiResponse.map((e) => true).toList();
    } else {
      visibility = apiResponse;
    }
    return IterableZip([
      _getButtonTextsForUserRole(visibility),
      _getButtonIconsForUserRole(visibility),
      _getButtonActionsForUserRole(visibility),
    ]);
  }
}
