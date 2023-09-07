import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/tinder_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

class TinderViewModel extends ChangeNotifier {
  Stream<bool> isUserRegistered() {
    return DatabaseService.database.child('tinder').onValue.map((event) {
      final data = tryCast<Map>(event.snapshot.value);
      if (data == null) {
        return false;
      }
      return data.keys.contains(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  Future register({required UserData user, required File image}) async {
    final imageUrl =
        await StorageService.uploadPic(file: image, path: 'tinder_images');
    final data =
        TinderData(name: user.name, teamNum: user.teamNum, imageUrl: imageUrl);
    await DatabaseService.database
        .child('tinder')
        .child(user.uid)
        .set(data.toJson());
  }
}
