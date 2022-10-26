import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        stream: picsRef.onChildAdded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final picRef = (snapshot.data!.snapshot.value as Map)['fileName'];
            print(picRef);
            return FutureBuilder(
              future: FirebaseStorage.instance
                  .ref()
                  .child('debug/$picRef.png')
                  .getDownloadURL(),
              builder: (context, url) {
                if (url.hasData) {
                  return Image.network(url.data!);
                }
                return const Text('Loading...');
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
