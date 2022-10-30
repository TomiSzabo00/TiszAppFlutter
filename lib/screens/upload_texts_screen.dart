import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/text_data.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class UploadTextsScreen extends StatelessWidget {
  const UploadTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szövegek feltöltése"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "Cím",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _textController,
              minLines: 3,
              maxLines: null,
              autocorrect: false,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Szöveg",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button3D(
                  onPressed: () {
                    var now = DateTime.now();
                    var formatter = DateFormat('yyyyMMddHHmmssSSS');
                    var key = formatter.format(now);
                    final text = TextData(
                        key: key,
                        title: _titleController.text,
                        text: _textController.text,
                        author: FirebaseAuth.instance.currentUser!.uid);
                    FirebaseDatabase.instance
                        .ref()
                        .child("debug/texts")
                        .child(text.key)
                        .set(text.toJson());
                  },
                  child: Text("Feltöltés"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
