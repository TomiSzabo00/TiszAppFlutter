import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'firebase_options.dart';
import 'widget_tree.dart';

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
      home: const WidgetTree(),
    );
  }
}
