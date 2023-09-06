// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button.dart';
import 'package:tiszapp_flutter/models/main_menu/main_menu_button_type.dart';
import 'package:tiszapp_flutter/models/main_menu/visibility_type.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/views/karoke/karaoke_basic_screen.dart';
import 'package:tiszapp_flutter/views/menu_buttons_screen.dart';
import 'package:tiszapp_flutter/views/notification_screen.dart';
import 'package:tiszapp_flutter/views/pics/pictures_screen.dart';
import 'package:tiszapp_flutter/views/quiz/quiz_screen.dart';
import 'package:tiszapp_flutter/views/quiz/slow_quiz_screen.dart';
import 'package:tiszapp_flutter/views/schedule_screen.dart';
import 'package:tiszapp_flutter/views/scores_screen.dart';
import 'package:tiszapp_flutter/views/songs_screen.dart';
import 'package:tiszapp_flutter/views/sports_result_view_screen.dart';
import 'package:tiszapp_flutter/views/sports_screen.dart';
import 'package:tiszapp_flutter/views/texts_screen.dart';
import 'package:tiszapp_flutter/views/pics/select_pictures_screen.dart';
import 'package:tiszapp_flutter/views/tinder/tinder_registration_screen.dart';
import 'package:tiszapp_flutter/views/upload_score_screen.dart';
import 'package:tiszapp_flutter/views/upload_texts_screen.dart';
import 'package:tiszapp_flutter/views/voting_screen.dart';
import 'package:tiszapp_flutter/views/wordle_screen.dart';
import 'package:tiszapp_flutter/views/hazas_parbaj_screen.dart';
import 'package:tiszapp_flutter/views/ejjeli_portya_admin_screen.dart';
import 'package:tiszapp_flutter/views/ejjeli_portya_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenuViewModel extends ChangeNotifier {
  MainMenuViewModel();
  UserData user = UserData.empty();

  List<MainMenuButton> buttons = [];
  List<MainMenuButton> buttonToggles = [];

  DatabaseReference database = DatabaseService.database;

  void subscribeToButtonEvents() async {
    if (user.uid.isEmpty) {
      user = await DatabaseService.getUserData(
          FirebaseAuth.instance.currentUser!.uid);
      notifyListeners();
    }

    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        buttons.clear();
        return;
      }
      DatabaseService.getUserData(firebaseUser.uid).then((value) {
        buttons.clear();
        user = value;
        database.child('_main_menu').once().then((event) {
          _addAllButtons(event);
        });
        notifyListeners();
      });
      FirebaseMessaging.instance.getToken().then((token) {
        if (FirebaseAuth.instance.currentUser != null && token != null) {
          database
              .child("notification_tokens")
              .child(FirebaseAuth.instance.currentUser!.uid)
              .set(token);
        }
      });
    });

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
      notifyListeners();
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

  void _addAllButtons(DatabaseEvent event) {
    final snapshot = event.snapshot;
    final values = tryCast<Map>(snapshot.value) ?? {};
    values.forEach((key, value) {
      final buttonType = _getButtonFromKey(key);
      final visibility = _getVisibilityFromKey(value);
      final button =
          MainMenuButton(type: buttonType, visibilityType: visibility);
      //the last part is for the reviewers to see the buttons no matter the settings
      if (user.isAdmin || button.isVisible || user.name == "Test User") {
        if (!buttons.any((element) => element.title == button.title)) {
          buttons.add(button);
        }
      }
      _reorderButtons();
      if (!buttonToggles.any((element) => element.title == button.title)) {
        buttonToggles.add(button);
      }
    });
    notifyListeners();
  }

  void _reorderButtons() {
    List<MainMenuButton> order = [
      MainMenuButton(type: MainMenuButtonType.schedule),
      MainMenuButton(type: MainMenuButtonType.tinder),
      MainMenuButton(type: MainMenuButtonType.scores),
      MainMenuButton(type: MainMenuButtonType.wordle),
      MainMenuButton(type: MainMenuButtonType.songs),
      MainMenuButton(type: MainMenuButtonType.pictures),
      MainMenuButton(type: MainMenuButtonType.reviewPics),
      MainMenuButton(type: MainMenuButtonType.texts),
      MainMenuButton(type: MainMenuButtonType.pictureUpload),
      MainMenuButton(type: MainMenuButtonType.textUpload),
      MainMenuButton(type: MainMenuButtonType.karaoke),
      MainMenuButton(type: MainMenuButtonType.nappaliPortya),
      MainMenuButton(type: MainMenuButtonType.quizQuick),
      MainMenuButton(type: MainMenuButtonType.slowQuiz),
      MainMenuButton(type: MainMenuButtonType.scoreUpload),
      MainMenuButton(type: MainMenuButtonType.voting),
      MainMenuButton(type: MainMenuButtonType.ejjeliportya),
      MainMenuButton(type: MainMenuButtonType.notifications),
      MainMenuButton(type: MainMenuButtonType.menuButtons),
      MainMenuButton(type: MainMenuButtonType.hazasParbaj),
      MainMenuButton(type: MainMenuButtonType.sports),
      MainMenuButton(type: MainMenuButtonType.sportResult)
    ];

    buttons.sort((a, b) => order
        .indexWhere((element) => element.type == a.type)
        .compareTo(order.indexWhere((element) => element.type == b.type)));

    // remove none type buttons from list
    buttons.removeWhere((element) => element.type == MainMenuButtonType.none);

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
    } else if (key == MainMenuButtonType.ejjeliportya.rawValue) {
      return MainMenuButtonType.ejjeliportya;
    } else if (key == MainMenuButtonType.notifications.rawValue) {
      return MainMenuButtonType.notifications;
    } else if (key == MainMenuButtonType.slowQuiz.rawValue) {
      return MainMenuButtonType.slowQuiz;
    } else if (key == MainMenuButtonType.reviewPics.rawValue) {
      return MainMenuButtonType.reviewPics;
    } else if (key == MainMenuButtonType.sports.rawValue) {
      return MainMenuButtonType.sports;
    } else if (key == MainMenuButtonType.sportResult.rawValue) {
      return MainMenuButtonType.sportResult;
    } else if (key == MainMenuButtonType.tinder.rawValue) {
      return MainMenuButtonType.tinder;
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
        return () async {
          final PermissionState ps =
              await PhotoManager.requestPermissionExtend();
          if (!ps.isAuth) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Figyelem'),
                content: const Text(
                    'A legjobb élmény érdekében kérlek engedélyezd az összes képhez való hozzáférést! Ezt utólag is megteheted a beállításokban.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectPicturesScreen(isAdmin: user.isAdmin),
                        ),
                      );
                    },
                    child: const Text('Nem engedélyezem'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await PhotoManager.openSetting();
                    },
                    child: const Text('Engedélyezem a beállításokban'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SelectPicturesScreen(isAdmin: user.isAdmin),
              ),
            );
          }
        };
      case MainMenuButtonType.pictures:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PicturesScreen(isReview: false, isAdmin: user.isAdmin),
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
                builder: (context) => const UploadScoreScreen(),
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
      case MainMenuButtonType.ejjeliportya:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => user.isAdmin
                    ? const EjjeliPortyaAdminScreen()
                    : const EjjeliPortyaScreen(),
              ),
            );
      case MainMenuButtonType.menuButtons:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MenuButtonsScreen(),
              ),
            );

      case MainMenuButtonType.hazasParbaj:
        return () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HazasParbajScreen(isAdmin: user.isAdmin)));
      case MainMenuButtonType.notifications:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
      case MainMenuButtonType.slowQuiz:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SlowQuizScreen(isAdmin: user.isAdmin),
              ),
            );
      case MainMenuButtonType.sports:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SportsScreen(),
              ),
            );
      case MainMenuButtonType.sportResult:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SportsResultViewScreen(),
              ),
            );
      case MainMenuButtonType.reviewPics:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PicturesScreen(isReview: true, isAdmin: user.isAdmin),
              ),
            );
      case MainMenuButtonType.tinder:
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TinderRegistrationScreen(),
              ),
            );
    }
  }

  _launchURL() async {
    final Uri url = Uri.parse(await _getDriveURL());
    try {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw FlutterError("Web page not available");
    }
  }

  Future<String> _getDriveURL() async {
    return await DatabaseService.getDriveURL(teamNum: user.teamNum);
  }

  void toggleButtonVisibility(
      {required MainMenuButton button, required bool isVisible}) {
    DatabaseReference ref = DatabaseService.database;
    ref.child('_main_menu/${button.type.rawValue}').set(isVisible ? 1 : 0);
  }
}
