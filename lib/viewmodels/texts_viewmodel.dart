// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/text_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class TextsViewModel with ChangeNotifier {
  List<TextData> texts = [];

  TextsViewModel() {
    initializeDateFormatting();
    _getTexts();
  }

  final DatabaseReference textsRef =
      FirebaseDatabase.instance.ref().child("debug/texts");

  UserData authorDetails = UserData.empty();

  void _getTexts() async {
    final textsRef = FirebaseDatabase.instance.ref().child("debug/texts");
    textsRef.onChildAdded.listen((event) {
      texts.insert(
          0,
          TextData.fromSnapshot(
              event.snapshot.key ?? "unknown", event.snapshot));
      notifyListeners();
    });
  }

  void uploadText(String title, String fullText) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    final text = TextData(
        key: key,
        title: title,
        text: fullText,
        author: FirebaseAuth.instance.currentUser!.uid);
    FirebaseDatabase.instance
        .ref()
        .child("debug/texts")
        .child(text.key)
        .set(text.toJson());
  }

  void getSelectedText(TextData text) async {
    textsRef.child('${text.key}/author').once().then((event) {
      DatabaseService.getUserData(event.snapshot.value.toString())
          .then((value) {
        authorDetails = value;
        notifyListeners();
      });
    });
  }
}
