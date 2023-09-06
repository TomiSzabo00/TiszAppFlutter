import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/services/database_service.dart';

class TinderViewModel extends ChangeNotifier {
  Stream<bool> isUserRegistered() {
    return (DatabaseService.database as DatabaseReference)
        .child('tinder')
        .onValue
        .map((event) {
          final data = tryCast<List>(event.snapshot.value);
          if (data == null) {
            return false;
          }
          return data.contains(FirebaseAuth.instance.currentUser!.uid);
        });
  }
}
