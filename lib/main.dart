import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'package:tiszapp_flutter/helpers/profile_screen_arguments.dart';
import 'package:tiszapp_flutter/viewmodels/karaoke/karaoke_basic_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/quiz_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/scores_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/songs_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/voting_viewmodel.dart';
import 'package:tiszapp_flutter/viewmodels/wordle_viewmodel.dart';
import 'package:tiszapp_flutter/views/karoke/karaoke_basic_screen.dart';
import 'package:tiszapp_flutter/views/profile_screen.dart';
import 'package:tiszapp_flutter/views/quiz_screen.dart';
import 'package:tiszapp_flutter/views/songs_detail_screen.dart';
import 'package:tiszapp_flutter/views/voting_screen.dart';
import 'package:tiszapp_flutter/views/wordle_screen.dart';
import 'firebase_options.dart';
import 'widget_tree.dart';
import 'package:tiszapp_flutter/views/schedule_screen.dart';
import 'package:tiszapp_flutter/views/scores_screen.dart';
import 'package:tiszapp_flutter/views/songs_screen.dart';
import 'package:tiszapp_flutter/views/upload_score_screen.dart';
import 'package:tiszapp_flutter/views/upload_pictures_screen.dart';
import 'package:tiszapp_flutter/views/upload_texts_screen.dart';
import 'package:tiszapp_flutter/views/pictures_screen.dart';
import 'package:tiszapp_flutter/views/texts_screen.dart';

// Hello Szakdolgozat!

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ScoresViewModel()),
      ChangeNotifierProvider(create: (_) => TextsViewModel()),
      ChangeNotifierProvider(create: (_) => VotingViewmodel()),
      ChangeNotifierProvider(create: (_) => SongsViewModel()),
      ChangeNotifierProvider(create: (_) => WordleViewModel()),
      ChangeNotifierProvider(create: (_) => QuizViewModel()),
      ChangeNotifierProvider(create: (_) => KaraokeBasicViewModel()),
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
        '/Képek feltöltése': (context) =>
            UploadPicturesScreen(context: context),
        '/Szövegek': (context) => const TextsScreen(),
        '/Szövegek feltöltése': (context) => UploadTextsScreen(),
        '/Daloskönyv': (context) => const SongsScreen(),
        '/Daloskönyv/Részlet': (context) => SongsDetailScreen(
            song: ModalRoute.of(context)!.settings.arguments as Song),
        '/Profil': (context) => ProfileScreen(
            args: ModalRoute.of(context)!.settings.arguments
                as ProfileScreenArguments),
        '/Szavazás': (context) => VotingScreen(),
        '/Wordle': (context) => const WordleScreen(),
        '/AV Kvíz': (context) => QuizScreen(
          isAdmin: ModalRoute.of(context)!.settings.arguments as bool,
        ),
        '/Karaoke': (context) => KaraokeBasicScreen(),
      },
      home: const WidgetTree(),
    );
  }
}
