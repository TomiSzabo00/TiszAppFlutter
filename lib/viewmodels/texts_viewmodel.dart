import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/models/text_data.dart';

class TextsViewModel with ChangeNotifier {
  List<TextData> texts = [];

  TextsViewModel() {
    _getTexts();
  }

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
}
