import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button_type.dart';
import 'package:tiszapp_flutter/models/main_menu/visibility_type.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/views/karoke/karaoke_basic_screen.dart';
import 'package:tiszapp_flutter/views/menu_buttons_screen.dart';
import 'package:tiszapp_flutter/views/pictures_screen.dart';
import 'package:tiszapp_flutter/views/quiz_screen.dart';
import 'package:tiszapp_flutter/views/schedule_screen.dart';
import 'package:tiszapp_flutter/views/scores_screen.dart';
import 'package:tiszapp_flutter/views/songs_screen.dart';
import 'package:tiszapp_flutter/views/texts_screen.dart';
import 'package:tiszapp_flutter/views/upload_pictures_screen.dart';
import 'package:tiszapp_flutter/views/upload_score_screen.dart';
import 'package:tiszapp_flutter/views/upload_texts_screen.dart';
import 'package:tiszapp_flutter/views/voting_screen.dart';
import 'package:tiszapp_flutter/views/wordle_screen.dart';
import 'package:tiszapp_flutter/views/hazas_parbaj_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenuViewModel extends ChangeNotifier {
  MainMenuViewModel();
  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);

  List<MainMenuButton> buttons = [];
  List<MainMenuButton> buttonToggles = [];

  void subscribeToButtonEvents() async {
    DatabaseReference database = FirebaseDatabase.instance.ref();
    if (user.uid.isEmpty) {
      user = await DatabaseService.getUserData(
          FirebaseAuth.instance.currentUser!.uid);
      notifyListeners();
    }

    database.child("_main_menu").onChildAdded.listen((event) {
      final snapshot = event.snapshot;
      final key = snapshot.key;
      final value = tryCast<int>(snapshot.value) ?? 0;
      if (key != null) {
        final buttonType = _getButtonFromKey(key);
        final visibility = _getVisibilityFromKey(value);
        final button =
            MainMenuButton(type: buttonType, visibilityType: visibility);
        if (user.isAdmin || button.isVisible) {
          if (!buttons.any((element) => element.title == button.title)) {
            buttons.add(button);
          }
        }
        _reorderButtons();
        if (!buttonToggles.any((element) => element.title == button.title)) {
          buttonToggles.add(button);
        }
      }
    });

    database.child("_main_menu").onChildChanged.listen((event) {
      final snapshot = event.snapshot;
      final key = snapshot.key;
      final value = tryCast<int>(snapshot.value) ?? 0;
      if (key != null) {
        final buttonType = _getButtonFromKey(key);
        final visibility = _getVisibilityFromKey(value);
        final button =
            MainMenuButton(type: buttonType, visibilityType: visibility);
        if (user.isAdmin || button.isVisible) {
          if (!buttons.any((element) => element.title == button.title)) {
            buttons.add(button);
          }
        } else {
          buttons.removeWhere((element) => element.title == button.title);
        }
        _reorderButtons();
        final index = buttonToggles
            .indexWhere((element) => element.title == button.title);
        if (index != -1) {
          buttonToggles[index] = button;
        }
      }
    });

    database.child("_main_menu").onChildRemoved.listen((event) {
      final snapshot = event.snapshot;
      final key = snapshot.key;
      if (key != null) {
        final buttonType = _getButtonFromKey(key);
        final button = MainMenuButton(type: buttonType);
        buttons.removeWhere((element) => element.title == button.title);
        _reorderButtons();
        buttonToggles.removeWhere((element) => element.title == button.title);
      }
    });
  }

  void _reorderButtons() {
    List<MainMenuButton> order = [
      MainMenuButton(type: MainMenuButtonType.schedule),
      MainMenuButton(type: MainMenuButtonType.scores),
      MainMenuButton(type: MainMenuButtonType.wordle),
      MainMenuButton(type: MainMenuButtonType.songs),
      MainMenuButton(type: MainMenuButtonType.pictures),
      MainMenuButton(type: MainMenuButtonType.texts),
      MainMenuButton(type: MainMenuButtonType.pictureUpload),
      MainMenuButton(type: MainMenuButtonType.textUpload),
      MainMenuButton(type: MainMenuButtonType.karaoke),
      MainMenuButton(type: MainMenuButtonType.nappaliPortya),
      MainMenuButton(type: MainMenuButtonType.quizQuick),
      MainMenuButton(type: MainMenuButtonType.scoreUpload),
      MainMenuButton(type: MainMenuButtonType.voting),
      MainMenuButton(type: MainMenuButtonType.menuButtons),
      MainMenuButton(type: MainMenuButtonType.hazasParbaj),
    ];

    buttons.sort((a, b) => order
        .indexWhere((element) => element.type == a.type)
        .compareTo(order.indexWhere((element) => element.type == b.type)));
    notifyListeners();
  }

  MainMenuButtonType _getButtonFromKey(String key) {
    if (key == MainMenuButtonType.karaoke.rawValue) {
      return MainMenuButtonType.karaoke;
    } else if (key == MainMenuButtonType.nappaliPortya.rawValue) {
      return MainMenuButtonType.nappaliPortya;
    } else if (key == MainMenuButtonType.pictureUpload.rawValue) {
      return MainMenuButtonType.pictureUpload;
    } else if (key == MainMenuButtonType.pictures.rawValue) {
      return MainMenuButtonType.pictures;
    } else if (key == MainMenuButtonType.quizQuick.rawValue) {
      return MainMenuButtonType.quizQuick;
    } else if (key == MainMenuButtonType.schedule.rawValue) {
      return MainMenuButtonType.schedule;
    } else if (key == MainMenuButtonType.scoreUpload.rawValue) {
      return MainMenuButtonType.scoreUpload;
    } else if (key == MainMenuButtonType.scores.rawValue) {
      return MainMenuButtonType.scores;
    } else if (key == MainMenuButtonType.songs.rawValue) {
      return MainMenuButtonType.songs;
    } else if (key == MainMenuButtonType.textUpload.rawValue) {
      return MainMenuButtonType.textUpload;
    } else if (key == MainMenuButtonType.texts.rawValue) {
      return MainMenuButtonType.texts;
    } else if (key == MainMenuButtonType.voting.rawValue) {
      return MainMenuButtonType.voting;
    } else if (key == MainMenuButtonType.wordle.rawValue) {
      return MainMenuButtonType.wordle;
    } else if (key == MainMenuButtonType.menuButtons.rawValue) {
      return MainMenuButtonType.menuButtons;
    } else if (key == MainMenuButtonType.hazasParbaj.rawValue) {
      return MainMenuButtonType.hazasParbaj;
    }

    return MainMenuButtonType.none;
  }

  VisibilityType _getVisibilityFromKey(int key) {
    switch (key) {
      case 0:
        return VisibilityType.hidden;
      case 1:
        return VisibilityType.visible;
      case 2:
        return VisibilityType.never;
      default:
        return VisibilityType.hidden;
    }
  }

  Function getActionFor(
      {required MainMenuButtonType buttonType, required BuildContext context}) {
    switch (buttonType) {
      case MainMenuButtonType.none:
        return () => {};
      case MainMenuButtonType.karaoke:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => KaraokeBasicScreen(isAdmin: user.isAdmin),
              ),
            );
      case MainMenuButtonType.nappaliPortya:
        return () => _launchURL();
      case MainMenuButtonType.pictureUpload:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UploadPicturesScreen(),
              ),
            );
      case MainMenuButtonType.pictures:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PicturesScreen(),
              ),
            );
      case MainMenuButtonType.quizQuick:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizScreen(isAdmin: user.isAdmin),
              ),
            );
      case MainMenuButtonType.schedule:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScheduleScreen(),
              ),
            );
      case MainMenuButtonType.scoreUpload:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UploadScoreScreen(),
              ),
            );
      case MainMenuButtonType.scores:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScoresScreen(),
              ),
            );
      case MainMenuButtonType.songs:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SongsScreen(),
              ),
            );
      case MainMenuButtonType.textUpload:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UploadTextsScreen(),
              ),
            );
      case MainMenuButtonType.texts:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TextsScreen(),
              ),
            );
      case MainMenuButtonType.voting:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VotingScreen(),
              ),
            );
      case MainMenuButtonType.wordle:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WordleScreen(),
              ),
            );
      case MainMenuButtonType.menuButtons:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MenuButtonsScreen(),
              ),
            );
      case MainMenuButtonType.hazasParbaj:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HazasParbajScreen(isAdmin: user.isAdmin),
              ),
            );
    }
  }

  _launchURL() async {
    final Uri url = Uri.parse(await _getDriveURL());
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<String> _getDriveURL() async {
    return await DatabaseService.getDriveURL(teamNum: user.teamNum);
  }

  void toggleButtonVisibility(
      {required MainMenuButton button, required bool isVisible}) {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    ref.child('_main_menu/${button.type.rawValue}').set(isVisible ? 1 : 0);
  }
}
