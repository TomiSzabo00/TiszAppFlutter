import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../viewmodels/sports_viewmodel.dart';
import '../widgets/3d_button.dart';
import '../widgets/input_field.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => SportsScreenState();
}

class SportsScreenState extends State<SportsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SportsViewModel>(context, listen: false).getData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme
        .of(context)
        .brightness == Brightness.dark;
    final viewModel = context.watch<SportsViewModel>();
    //viewModel.getData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sport Eredmény Feltöltése"),
      ),
      body: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Milyen sportág?"),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      hint: const Text("Válassz sportágat"),
                      onChanged: (s) => viewModel.chooseSport(s),
                      items: viewModel.getAvailableSports().map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: viewModel.initializedSportType ? viewModel.sportType : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 25),
                    const Text("Melyik csapatok játszottak?"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: DropdownButton<int>(
                              hint: const Text("Csapat1"),
                              onChanged: (s) => viewModel.chooseTeam(s, 1),
                              items: viewModel.getAvailableTeams(1).map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              value: viewModel.initializedTeam1 ? viewModel.team1 : null,
                              isExpanded: true,
                            ),
                        ),
                      ),
                        Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DropdownButton<int>(
                            hint: const Text("Csapat2"),
                            onChanged: (s) => viewModel.chooseTeam(s, 2),
                            items: viewModel.getAvailableTeams(2).map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            value: viewModel.initializedTeam2 ? viewModel.team2 : null,
                            isExpanded: true,
                          ),
                        ),
                      ),]
                    ),
                    const Text("Mi lett a végeredmény?"),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: InputField(
                                controller:
                                viewModel.team1ScoreController,
                                placeholder: "0",
                                isNumber: true,
                                maxChar: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: InputField(
                                controller:
                                viewModel.team2ScoreController,
                                placeholder: "0",
                                isNumber: true,
                                maxChar: 2,
                              ),
                            ),
                          ),]
                    ),
                    const SizedBox(height: 25),
                    const Text("Ki lett az MVP?"),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        width: 200,
                        child: AbsorbPointer(
                          absorbing: !(viewModel.initializedTeam1 && viewModel.initializedTeam2),
                          child: DropdownButton<String>(
                            hint: const Text("Válassz játékost"),
                            onChanged: (s) => viewModel.chooseMVP(s),
                            items: viewModel.getAvailablePlayers().map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: viewModel.initializedMVP ? viewModel.MVP : null,
                            isExpanded: true,
                          ),
                        ),
                      )
                    ]),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button3D(
                          onPressed: () {
                            viewModel.uploadResult();
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
            ])
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sikeres feltöltés"),
          content: const Text("Az eredmény sikeresen feltöltésre került."),
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