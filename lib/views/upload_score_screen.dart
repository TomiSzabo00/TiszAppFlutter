import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

import '../viewmodels/scores_viewmodel.dart';

class UploadScoreScreen extends StatelessWidget {
  UploadScoreScreen({super.key});

  final _nameController = TextEditingController();
  final _score1Controller = TextEditingController();
  final _score2Controller = TextEditingController();
  final _score3Controller = TextEditingController();
  final _score4Controller = TextEditingController();
  final _viewModel = ScoresViewModel();

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
                      _viewModel.uploadScore(
                          _nameController.text,
                          _score1Controller.text,
                          _score2Controller.text,
                          _score3Controller.text,
                          _score4Controller.text);
                      _clearFields();
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
