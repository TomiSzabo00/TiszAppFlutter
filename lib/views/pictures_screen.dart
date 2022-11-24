import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/data/picture_data.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';

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
            final List<Picture> pics = [];
            values.forEach((key, value) {
              final pic = Picture.fromSnapshot(key, value);
              pics.add(pic);
            });
            pics.sort((a, b) => b.key.compareTo(a.key));
            for (var pic in pics) {
              children.add(PictureItem(pic: pic));
            }
            return GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              childAspectRatio: 1.2,
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
