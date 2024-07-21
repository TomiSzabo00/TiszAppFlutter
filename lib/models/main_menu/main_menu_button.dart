import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button_type.dart';
import 'package:tiszapp_flutter/models/main_menu/visibility_type.dart';

class MainMenuButton {
  final MainMenuButtonType type;
  VisibilityType visibilityType;

  String get title {
    switch (type) {
      case MainMenuButtonType.none:
        return 'Hiba';
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
      case MainMenuButtonType.combinedScoreUpload:
        return 'Csapatok pontozása';
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
      case MainMenuButtonType.menuButtons:
        return 'Főmenü gombok';
      case MainMenuButtonType.hazasParbaj:
        return 'Házas párbaj';
      case MainMenuButtonType.ejjeliportya:
        return 'Éjjeli portya';
      case MainMenuButtonType.notifications:
        return 'Értesítések';
      case MainMenuButtonType.slowQuiz:
        return 'Lassú kvíz';
      case MainMenuButtonType.reviewPics:
        return 'Képek ellenőrzése';
      case MainMenuButtonType.sports:
        return 'Sport Feltöltés';
      case MainMenuButtonType.sportResult:
        return 'Sport Eredmények';
      case MainMenuButtonType.chantBlaster:
        return 'Chant Blaster';
      case MainMenuButtonType.radioWishes:
        return 'Zenekérés';
    }
  }

  IconData get icon {
    switch (type) {
      case MainMenuButtonType.none:
        return Icons.error;
      case MainMenuButtonType.karaoke:
        return Icons.mic;
      case MainMenuButtonType.nappaliPortya:
        return Icons.holiday_village_outlined;
      case MainMenuButtonType.pictureUpload:
        return Icons.upload_rounded;
      case MainMenuButtonType.pictures:
        return Icons.image;
      case MainMenuButtonType.quizQuick:
        return Icons.front_hand;
      case MainMenuButtonType.schedule:
        return Icons.calendar_today;
      case MainMenuButtonType.combinedScoreUpload:
        return Icons.control_point_sharp;
      case MainMenuButtonType.scores:
        return Icons.format_list_numbered;
      case MainMenuButtonType.songs:
        return Icons.music_note;
      case MainMenuButtonType.textUpload:
        return Icons.upload_rounded;
      case MainMenuButtonType.texts:
        return Icons.text_fields;
      case MainMenuButtonType.voting:
        return Icons.how_to_vote;
      case MainMenuButtonType.wordle:
        return Icons.type_specimen;
      case MainMenuButtonType.ejjeliportya:
        return Icons.holiday_village_outlined;
      case MainMenuButtonType.menuButtons:
        return Icons.toggle_on_outlined;
      case MainMenuButtonType.hazasParbaj:
        return Icons.favorite;
      case MainMenuButtonType.notifications:
        return Icons.notifications;
      case MainMenuButtonType.slowQuiz:
        return Icons.edit_note_rounded;
      case MainMenuButtonType.reviewPics:
        return Icons.image_search;
      case MainMenuButtonType.sports:
        return Icons.sports_soccer;
      case MainMenuButtonType.sportResult:
        return Icons.sports_score;
      case MainMenuButtonType.radioWishes:
        return Icons.radio;
      case MainMenuButtonType.chantBlaster:
        return Icons.volume_up;
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
