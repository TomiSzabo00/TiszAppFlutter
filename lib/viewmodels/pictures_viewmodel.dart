import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';

import '../models/picture_data.dart';

class PicturesViewModel {
  final DatabaseReference picsRef =
      FirebaseDatabase.instance.ref().child("debug/pics");

  List<Widget> handlePics(AsyncSnapshot snapshot) {
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
    return children;
  }
}
