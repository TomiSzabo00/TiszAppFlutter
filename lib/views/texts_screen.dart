import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/text_data.dart';
import 'package:tiszapp_flutter/widgets/text_item.dart';

class TextsScreen extends StatefulWidget {
  const TextsScreen({super.key});

  @override
  State<TextsScreen> createState() => _TextsScreenState();
}

class _TextsScreenState extends State<TextsScreen> {
  List<TextData> texts = [];

  @override
  void initState() {
    FirebaseDatabase.instance
        .ref()
        .child("debug/texts")
        .onChildAdded
        .listen((event) {
      setState(() {
        texts.insert(
            0,
            TextData.fromSnapshot(
                event.snapshot.key ?? "unknown", event.snapshot));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szövegek'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: isDarkTheme
                ? const AssetImage('images/bg2_night.png')
                : const AssetImage('images/bg2_day.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: 3,
          children: [
            for (final text in texts)
              TextItem(
                text: text,
              ),
          ],
        ),
      ),
    );
  }
}
