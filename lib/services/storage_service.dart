import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart' as database;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'dart:convert' show utf8;

class StorageService {
  static storage.Reference ref = storage.FirebaseStorage.instance.ref();
  static uploadImage(XFile file, String title) async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    final images = ref.child('debug/$key.jpg');
    final storage.UploadTask uploadTask = images.putData(
        await file.readAsBytes(),
        storage.SettableMetadata(contentType: 'image/jpeg'));
    final storage.TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());
    //return url;

    final database.DatabaseReference picsRef =
        database.FirebaseDatabase.instance.ref().child("debug/pics");
    picsRef.child(key).set({
      'fileName': url,
      'author': FirebaseAuth.instance.currentUser!.uid,
      'title': title.isEmpty ? key : title,
    });
  }

  static Future<List<Song>> getSongs() async {
    final data =
        await storage.FirebaseStorage.instance.ref().child('songs').listAll();
    final songs = <Song>[];
    for (var item in data.items) {
      final lyricsLink = await storage.FirebaseStorage.instance
          .ref()
          .child('songs/${item.name}')
          .getDownloadURL();
      final lyrics = await http.read(Uri.parse(lyricsLink));
      final song = Song(
        name: item.name.substring(0, item.name.length - 4).toUpperCase(),
        lyrics: lyrics,
      );
      songs.add(song);
    }
    return songs;
  }

  static readTextFromURL(String url) async {
    final uri = Uri.parse(url);
    http.get(uri).then((content) {
      return content;
    });
  }
}
