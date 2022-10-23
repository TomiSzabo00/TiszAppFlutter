import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/data/score_data.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class UploadScoreScreen extends StatelessWidget {
  UploadScoreScreen({super.key}) {
    initializeDateFormatting();
  }

  final _nameController = TextEditingController();
  final _score1Controller = TextEditingController();
  final _score2Controller = TextEditingController();
  final _score3Controller = TextEditingController();
  final _score4Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pontok feltöltése"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mire adod a pontot?"),
              const SizedBox(height: 10),
              InputField(
                controller: _nameController,
                placeholder: "Program neve",
                icon: const Icon(Icons.edit),
              ),
              const SizedBox(height: 30),
              const Text("Hány pontot adsz a csatoknak?"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text("1."),
                  Text("2."),
                  Text("3."),
                  Text("4."),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 70) / 4,
                    child: InputField(
                      controller: _score1Controller,
                      placeholder: "0",
                      isNumber: true,
                      maxChar: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 70) / 4,
                    child: InputField(
                      controller: _score2Controller,
                      placeholder: "0",
                      isNumber: true,
                      maxChar: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 70) / 4,
                    child: InputField(
                      controller: _score3Controller,
                      placeholder: "0",
                      isNumber: true,
                      maxChar: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 70) / 4,
                    child: InputField(
                      controller: _score4Controller,
                      placeholder: "0",
                      isNumber: true,
                      maxChar: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button3D(
                    onPressed: () {
                      _uploadScore();
                      _showDialog(context);
                    },
                    child: Text(
                      "Feltöltés",
                      style: TextStyle(
                        color: isDarkTheme
                            ? CustomColor.btnTextNight
                            : CustomColor.btnTextDay,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _uploadScore() {
    var name = _nameController.text;
    var score1 = _score1Controller.text;
    var score2 = _score2Controller.text;
    var score3 = _score3Controller.text;
    var score4 = _score4Controller.text;

    var score = Score(
      author: FirebaseAuth.instance.currentUser!.uid,
      name: name,
      score1: _scoreTextToInt(score1),
      score2: _scoreTextToInt(score2),
      score3: _scoreTextToInt(score3),
      score4: _scoreTextToInt(score4),
    );

    var ref = FirebaseDatabase.instance.ref().child("debug/scores");
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    ref.child(key).set(score.toJson());

    _clearFields();
  }

  int _scoreTextToInt(String text) {
    if (text == "") {
      return 0;
    } else {
      return int.tryParse(text) ?? 0;
    }
  }

  void _clearFields() {
    _nameController.clear();
    _score1Controller.clear();
    _score2Controller.clear();
    _score3Controller.clear();
    _score4Controller.clear();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sikeres feltöltés"),
          content: const Text("A pontok sikeresen feltöltésre kerültek."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
