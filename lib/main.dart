import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/song_data.dart';
import 'package:tiszapp_flutter/screens/profile_screen.dart';
import 'package:tiszapp_flutter/screens/songs_detail_screen.dart';
import 'firebase_options.dart';
import 'widget_tree.dart';
import 'package:tiszapp_flutter/screens/schedule_screen.dart';
import 'package:tiszapp_flutter/screens/scores_screen.dart';
import 'package:tiszapp_flutter/screens/songs_screen.dart';
import 'package:tiszapp_flutter/screens/upload_score_screen.dart';
import 'package:tiszapp_flutter/screens/upload_pictures_screen.dart';
import 'package:tiszapp_flutter/screens/upload_texts_screen.dart';
import 'package:tiszapp_flutter/screens/pictures_screen.dart';
import 'package:tiszapp_flutter/screens/texts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        iconTheme: const IconThemeData(color: CustomColor.btnTextDay),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: CustomColor.white,
        iconTheme: const IconThemeData(color: CustomColor.btnTextNight),
      ),
      routes: {
        '/Napirend': (context) => const ScheduleScreen(),
        '/Pontállás': (context) => const ScoresScreen(),
        '/Pontok feltöltése': (context) => UploadScoreScreen(),
        '/Képek': (context) => const PicturesScreen(),
        '/Képek feltöltése': (context) => const UploadPicturesScreen(),
        '/Szövegek': (context) => const TextsScreen(),
        '/Szövegek feltöltése': (context) => const UploadTextsScreen(),
        '/Daloskönyv': (context) => const SongsScreen(),
        '/Daloskönyv/Részlet': (context) => SongsDetailScreen(
            song: ModalRoute.of(context)!.settings.arguments as Song),
        '/Profil': (context) => const ProfileScreen(),
      },
      home: const WidgetTree(),
    );
  }
}
