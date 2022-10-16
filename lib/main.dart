import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'firebase_options.dart';
import 'widget_tree.dart';
import 'package:tiszapp_flutter/screens/schedule_screen.dart';

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
        '/Pontállás': (context) => const ScheduleScreen(),
        '/Pontok feltöltése': (context) => const ScheduleScreen(),
        '/Képek': (context) => const ScheduleScreen(),
        '/Képek feltöltése': (context) => const ScheduleScreen(),
        '/Szövegek': (context) => const ScheduleScreen(),
        '/Szövegek feltöltése': (context) => const ScheduleScreen(),
        '/Daloskönyv': (context) => const ScheduleScreen(),
      },
      home: const WidgetTree(),
    );
  }
}
