import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class NotificationViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  List<bool> switches = List.empty(growable: true);

  void initSwitches() {
    final database = FirebaseDatabase.instance.ref();
    database.child('number_of_teams').onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      // decode data
      final data = tryCast<int>(event.snapshot.value) ?? 4;
      switches = List.generate(data, (index) => false);
      notifyListeners();
    });
  }
}
