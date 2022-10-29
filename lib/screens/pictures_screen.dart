import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PicturesScreen extends StatefulWidget {
  const PicturesScreen({super.key});

  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  final DatabaseReference picsRef =
      FirebaseDatabase.instance.ref().child("debug/pics");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Képek'),
      ),
      body: StreamBuilder(
        stream: picsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            final Map<dynamic, dynamic> values =
                snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
            final List<Widget> children = [];
            values.forEach((key, value) {
              final String ref = value['fileName'];
              children.add(Image.network(ref));
            });
            return ListView(
              children: children,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
