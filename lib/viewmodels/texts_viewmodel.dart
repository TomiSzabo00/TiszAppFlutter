import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/models/text_data.dart';

class TextsViewModel {
  List<TextData> texts = [];

  Future<void> getTexts() async {
    final textsRef = FirebaseDatabase.instance.ref().child("debug/texts");
    textsRef.onChildAdded.listen((event) {
      texts.insert(
          0,
          TextData.fromSnapshot(
              event.snapshot.key ?? "unknown", event.snapshot));
    });
  }
}
