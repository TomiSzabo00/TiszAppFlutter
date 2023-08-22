import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/hazas_parbaj_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/ejjeli_portya_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/karaoke/karaoke_basic_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/main_menu_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/notification_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/quiz_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/quiz/slow_quiz_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/scores_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/songs_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/sports_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/voting_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/wordle_viewmodel.dart';
import 'firebase_options.dart';
import 'widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Tiszapp',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('User granted permission: ${settings.authorizationStatus}');
  }

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => MainMenuViewModel()),
      ChangeNotifierProvider(create: (_) => ScoresViewModel()),
      ChangeNotifierProvider(create: (_) => TextsViewModel()),
      ChangeNotifierProvider(create: (_) => PicturesViewModel()),
      ChangeNotifierProvider(create: (_) => VotingViewmodel()),
      ChangeNotifierProvider(create: (_) => SongsViewModel()),
      ChangeNotifierProvider(create: (_) => WordleViewModel()),
      ChangeNotifierProvider(create: (_) => QuizViewModel()),
      ChangeNotifierProvider(create: (_) => KaraokeBasicViewModel()),
      ChangeNotifierProvider(create: (_) => HazasParbajViewModel()),
      ChangeNotifierProvider(create: (_) => EjjeliPortyaViewModel()),
      ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ChangeNotifierProvider(create: (_) => SlowQuizViewModel()),
      ChangeNotifierProvider(create: (_) => SportsViewModel()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: CustomColor.btnFaceDay,
          foregroundColor: CustomColor.btnTextDay,
        ),
        primarySwatch: Colors.green,
        iconTheme: const IconThemeData(color: CustomColor.btnTextDay),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: CustomColor.btnFaceNight,
          foregroundColor: CustomColor.btnTextNight,
        ),
        brightness: Brightness.dark,
        primarySwatch: CustomColor.white,
        iconTheme: const IconThemeData(color: CustomColor.btnTextNight),
      ),
      home: const WidgetTree(),
    );
  }
}
