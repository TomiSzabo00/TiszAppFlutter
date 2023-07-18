import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

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
            return ListView(
                children: [Padding(
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
                  const SizedBox(height: 25),
                  const Text("Hány pontot értek el a csapatok?"),
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
                  const SizedBox(height: 25),
                  const Text("Hogyan történjen a pontok szétosztása?"),
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        SizedBox(width: 200, child:
                            AbsorbPointer(
                                absorbing: !_viewModel.baseScoresAdded(),
                                child: DropdownButton<String>(
                                  onChanged: (s) => _viewModel.chooseDistr(s),
                                  items: _viewModel.getAvailableDistrs().map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )
                            ))
                      ]
                  ),
                  const SizedBox(height: 25),
                  const Text("Hány pontot kap a legjobb csapat?"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child:
                            SizedBox(width: 200, child:
                            AbsorbPointer(
                              absorbing: !_viewModel.baseScoresAdded(),
                              child: InputField(
                                controller: _viewModel.maxController,
                                onChanged: () => _viewModel.maxChanged(),
                                placeholder: "100",
                                isNumber: true,
                                maxChar: 3,
                              ),
                            ))
                      ),]
                  ),
                  const SizedBox(height: 25),
                  const Text("Végső pontszámok"),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child:
                          AbsorbPointer(
                            absorbing: !_viewModel.baseScoresAdded(),
                            child: InputField(
                              controller: _viewModel.finalScoreControllers[index],
                              placeholder: "0",
                              isNumber: true,
                              maxChar: 3,
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
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
            )]);
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
