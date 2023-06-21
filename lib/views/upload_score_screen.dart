import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

import '../viewmodels/scores_viewmodel.dart';

class UploadScoreScreen extends StatelessWidget {
  UploadScoreScreen({super.key});

  final _viewModel = ScoresViewModel();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pontok feltöltése"),
      ),
      body: FutureBuilder(
        future: _viewModel.getNumberOfTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mire adod a pontot?"),
                  const SizedBox(height: 10),
                  InputField(
                    controller: _viewModel.nameController,
                    placeholder: "Program neve",
                    icon: const Icon(Icons.edit),
                  ),
                  const SizedBox(height: 30),
                  const Text("Hány pontot adsz a csatoknak?"),
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                          snapshot.data!, (index) => Text('${index + 1}.'))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      snapshot.data!,
                      (index) => Expanded(
                        // width:
                        //     MediaQuery.of(context).size.width / snapshot.data! -
                        //         10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InputField(
                            controller: _viewModel.scoreControllers[index],
                            placeholder: "0",
                            isNumber: true,
                            maxChar: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button3D(
                        onPressed: () {
                          _viewModel.uploadScore();
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
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
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
