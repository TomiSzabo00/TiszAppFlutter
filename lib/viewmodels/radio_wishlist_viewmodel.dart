// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/radio_wish_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tiszapp_flutter/services/storage_service.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class RadioWishlistViewModel with ChangeNotifier {
  List<RadioWish> radioWishes = [];

  RadioWishlistViewModel() {
    initializeDateFormatting();
    _getRadioWishes();
  }

  final DatabaseReference radioWishesRef =
      DatabaseService.database.child("radioWishes");

  UserData authorDetails = UserData.empty();

  void _getRadioWishes() async {
    final radioWishesRef = DatabaseService.database.child("radioWishes");
    radioWishesRef.onChildAdded.listen((event) {
      radioWishes.insert(
          0,
          RadioWish.fromSnapshot(
              event.snapshot.key ?? "unknown", event.snapshot));
      notifyListeners();
    });
  }

  void uploadRadioWish(String name, String url) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    final wish = RadioWish(
        key: key,
        name: name,
        url: url,
        user: FirebaseAuth.instance.currentUser!.uid);
    DatabaseService.database
        .child("radioWishes")
        .child(wish.key)
        .set(wish.toJson());
  }

  void getSelectedRadioWish(RadioWish wish) async {
    radioWishesRef.child('${wish.key}/user').once().then((event) {
      DatabaseService.getUserData(event.snapshot.value.toString())
          .then((value) {
        authorDetails = value;
        notifyListeners();
      });
    });
  }

  Future<void> deleteRadioWish(RadioWish wish) async {
    radioWishesRef.child(wish.key).remove();
  }
}
