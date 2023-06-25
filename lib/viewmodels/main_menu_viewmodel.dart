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
import 'package:url_launcher/url_launcher.dart';

class MainMenuViewModel extends ChangeNotifier {
  MainMenuViewModel();
  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);

  List<MainMenuButton> buttons = [];

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
            notifyListeners();
          }
        }
      }
    });
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
    } else {
      return MainMenuButtonType.none;
    }
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

  Function getActionFor({required MainMenuButtonType buttonType, required BuildContext context}) {
    switch (buttonType) {
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
                builder: (context) => UploadPicturesScreen(context: context),
              ),
            );
      case MainMenuButtonType.pictures:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UploadPicturesScreen(context: context),
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
      case MainMenuButtonType.none:
        return () => {};
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
}
