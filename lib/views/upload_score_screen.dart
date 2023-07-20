import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/scores/distribution_type.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

import '../viewmodels/scores_viewmodel.dart';

class UploadScoreScreen extends StatefulWidget {
  const UploadScoreScreen({super.key});

  @override
  UploadScoreScreenState createState() => UploadScoreScreenState();
}

class UploadScoreScreenState extends State<UploadScoreScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final viewModel = context.watch<ScoresViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pontok feltöltése"),
      ),
      body: FutureBuilder(
        future: viewModel.getNumberOfTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mire adod a pontot?"),
                    const SizedBox(height: 10),
                    InputField(
                      controller: viewModel.nameController,
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: InputField(
                              controller:
                                  viewModel.scoreControllers.length > index
                                      ? viewModel.scoreControllers[index]
                                      : TextEditingController(),
                              placeholder: "0",
                              isNumber: true,
                              maxChar: 3,
                              onChanged: () {
                                viewModel.areBaseScoresAdded();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text("Hogyan történjen a pontok szétosztása?"),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        width: 200,
                        child: AbsorbPointer(
                          absorbing: !viewModel.areAllScoresAdded,
                          child: DropdownButton<DistributionType>(
                            hint: const Text("Válassz elosztást"),
                            onChanged: (s) => viewModel.chooseDistr(s),
                            items: viewModel.getAvailableDistrs().map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                            value: viewModel.chosenDistr,
                            isExpanded: true,
                          ),
                        ),
                      )
                    ]),
                    const SizedBox(height: 25),
                    const Text("Hány pontot kap a legjobb csapat?"),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                              width: 200,
                              child: AbsorbPointer(
                                absorbing: !viewModel.areAllScoresAdded,
                                child: InputField(
                                  controller: viewModel.maxController,
                                  onChanged: () => viewModel.maxChanged(),
                                  placeholder: "100",
                                  isNumber: true,
                                  maxChar: 3,
                                ),
                              ))),
                    ]),
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
                            child: AbsorbPointer(
                                absorbing: !viewModel.areAllScoresAdded,
                                child: InputField(
                                  controller: viewModel
                                              .finalScoreControllers.length >
                                          index
                                      ? viewModel.finalScoreControllers[index]
                                      : TextEditingController(),
                                  placeholder: "0",
                                  isNumber: true,
                                  maxChar: 3,
                                )),
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
                            viewModel.uploadScore();
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
              )
            ]);
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
