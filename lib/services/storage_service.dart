import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiszapp_flutter/models/song_data.dart';
import 'dart:convert' show json, utf8;

class StorageService {
  static storage.Reference ref = storage.FirebaseStorage.instance.ref();
  static Future<String> uploadImage(XFile file, String title) async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    final images = ref.child('debug/$key.jpg');
    final storage.UploadTask uploadTask = images.putData(
        await file.readAsBytes(),
        storage.SettableMetadata(contentType: 'image/jpeg'));
    final storage.TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

  static deleteImage(String url) async {
    final ref = storage.FirebaseStorage.instance.refFromURL(url);
    await ref.delete();
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
      final lyrics = await readTextFromURL(lyricsLink);
      final song = Song(
        name: item.name.substring(0, item.name.length - 4).toUpperCase(),
        lyrics: lyrics,
      );
      songs.add(song);
    }
    return songs;
  }

  static Future<String> readTextFromURL(String url) async {
    final uri = Uri.parse(url);
    return await http.get(uri).then((content) {
      return utf8.decode(content.bodyBytes);
    });
  }

  static Future<Map<String, dynamic>> getServiceFile() async {
    const serviceFileNmae =
        'tiszapp-175fb-firebase-adminsdk-wj70k-b37db09c17.json';
    final data = await storage.FirebaseStorage.instance
        .ref()
        .child('not_a_password/$serviceFileNmae')
        .getDownloadURL();
    final uri = Uri.parse(data);
    return await http.get(uri).then((content) {
      return json.decode(content.body);
    });
  }
}
