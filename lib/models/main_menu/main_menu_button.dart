import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button_type.dart';
import 'package:tiszapp_flutter/models/main_menu/visibility_type.dart';

class MainMenuButton {
  final MainMenuButtonType type;
  VisibilityType visibilityType;

  String get title {
    switch (type) {
      case MainMenuButtonType.karaoke:
        return 'Karaoke';
      case MainMenuButtonType.nappaliPortya:
        return 'Nappali portya';
      case MainMenuButtonType.pictureUpload:
        return 'Kép feltöltése';
      case MainMenuButtonType.pictures:
        return 'Képek';
      case MainMenuButtonType.quizQuick:
        return 'AV Kvíz';
      case MainMenuButtonType.schedule:
        return 'Napirend';
      case MainMenuButtonType.scoreUpload:
        return 'Pontok feltöltése';
      case MainMenuButtonType.scores:
        return 'Pontállás';
      case MainMenuButtonType.songs:
        return 'Daloskönyv';
      case MainMenuButtonType.textUpload:
        return 'Szövegek feltöltése';
      case MainMenuButtonType.texts:
        return 'Szövegek';
      case MainMenuButtonType.voting:
        return 'Szavazás';
      case MainMenuButtonType.wordle:
        return 'Wordle';
      default:
        return 'Hiba';
    }
  }

  IconData get icon {
    switch (type) {
      case MainMenuButtonType.karaoke:
        return Icons.mic;
      case MainMenuButtonType.nappaliPortya:
        return Icons.holiday_village_outlined;
      case MainMenuButtonType.pictureUpload:
        return Icons.add;
      case MainMenuButtonType.pictures:
        return Icons.image;
      case MainMenuButtonType.quizQuick:
        return Icons.front_hand;
      case MainMenuButtonType.schedule:
        return Icons.calendar_today;
      case MainMenuButtonType.scoreUpload:
        return Icons.add;
      case MainMenuButtonType.scores:
        return Icons.format_list_numbered;
      case MainMenuButtonType.songs:
        return Icons.music_note;
      case MainMenuButtonType.textUpload:
        return Icons.add;
      case MainMenuButtonType.texts:
        return Icons.text_fields;
      case MainMenuButtonType.voting:
        return Icons.how_to_vote;
      case MainMenuButtonType.wordle:
        return Icons.type_specimen;
      default:
        return Icons.error;
    }
  }

  bool get isVisible {
    if (visibilityType == VisibilityType.visible) {
      return true;
    }
    return false;
  }

  MainMenuButton({
    required this.type,
    this.visibilityType = VisibilityType.hidden,
  });
}