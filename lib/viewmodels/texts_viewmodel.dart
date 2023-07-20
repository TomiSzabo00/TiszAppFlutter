// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/models/text_data.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../widgets/text_item.dart';

class TextsViewModel with ChangeNotifier {
  List<TextData> texts = [];

  TextsViewModel() {
    initializeDateFormatting();
    _getTexts();
  }

  TextsViewModel._fromContext(BuildContext context) {
    _context = context;
  }

  static Future<TextsViewModel> init(BuildContext context) async {
    return TextsViewModel._fromContext(context);
  }

  late BuildContext? _context;
  final DatabaseReference textsRef =
      FirebaseDatabase.instance.ref().child("debug/texts");

  TextData? text;

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

  void pickText(TextData text) {
    this.text = text;
  }

  void getSelectedText(TextData text) {
    this.text?.title = text.title;
    this.text?.author = text.author;
    this.text?.text = text.text;
    notifyListeners();
  }
}
