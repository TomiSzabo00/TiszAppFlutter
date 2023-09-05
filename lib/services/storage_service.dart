import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:tiszapp_flutter/models/song_data.dart';
import 'dart:convert' show json, utf8;
import 'package:tiszapp_flutter/services/date_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class StorageService {
  static get ref {
    if (kDebugMode) {
      return storage.FirebaseStorage.instance.ref().child('debug');
    } else {
      return storage.FirebaseStorage.instance.ref();
    }
  }

  static Future<List<String>> uploadImages(
      List<File> files, String title) async {
    List<String> urls = [];

    await Future.forEach(files, (file) async {
      final filePath = file.path;
      final fileExtension = extension(filePath);
      final lastIndex = filePath.lastIndexOf(RegExp(fileExtension));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
        var result = await FlutterImageCompress.compressAndGetFile(
          file.path,
          outPath,
          quality: 50,
        );
        file = File(result!.path);
      } else if (fileExtension == '.png') {
        var result = await FlutterImageCompress.compressAndGetFile(
          file.path,
          outPath,
          quality: 50,
          format: CompressFormat.png,
        );
        file = File(result!.path);
      } else if (fileExtension == '.heic') {
        var result = await FlutterImageCompress.compressAndGetFile(
          file.path,
          outPath,
          quality: 50,
          format: CompressFormat.heic,
        );
        file = File(result!.path);
      }

      var key = DateService.dateInMillisAsString();
      final images = ref.child('images/$key.jpg');
      final storage.UploadTask uploadTask = images.putData(
          await file.readAsBytes(),
          storage.SettableMetadata(contentType: 'image/jpeg'));
      final storage.TaskSnapshot downloadUrl = (await uploadTask);
      final String url = (await downloadUrl.ref.getDownloadURL());
      urls.add(url);
    });

    return urls;
  }

  static Future<String> uploadProfilePic(
      {required File file, required String uid}) async {
    // compress image
    final filePath = file.path;
    final fileExtension = extension(filePath);
    final lastIndex = filePath.lastIndexOf(RegExp(fileExtension));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        outPath,
        quality: 50,
      );
      file = File(result!.path);
    } else if (fileExtension == '.png') {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        outPath,
        quality: 50,
        format: CompressFormat.png,
      );
      file = File(result!.path);
    } else if (fileExtension == '.heic') {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        outPath,
        quality: 50,
        format: CompressFormat.heic,
      );
      file = File(result!.path);
    }

    final images = storage.FirebaseStorage.instance
        .ref()
        .child('profile_pictures/$uid.jpg');
    final storage.UploadTask uploadTask = images.putData(
        await file.readAsBytes(),
        storage.SettableMetadata(contentType: 'image/jpeg'));
    final storage.TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

  static deleteImage(List<String> urls) async {
    await Future.forEach(urls, (url) async {
      final ref = storage.FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    });
  }

  static Future<List<Song>> getSongs() async {
    final data = await ref.child('songs').listAll();
    final songs = <Song>[];
    for (var item in data.items) {
      final lyricsLink = await ref.child('songs/${item.name}').getDownloadURL();
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
