import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

import '../../viewmodels/ocsi_scores_viewmodel.dart';

class UploadOcsiScoreScreen extends StatefulWidget {
  const UploadOcsiScoreScreen({super.key});

  @override
  UploadOcsiScoreScreenState createState() => UploadOcsiScoreScreenState();
}

class UploadOcsiScoreScreenState extends State<UploadOcsiScoreScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final viewModel = context.watch<OcsiScoresViewModel>();
    return Scaffold(
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
                    const Text("Mire adod a öcsit?"),
                    const SizedBox(height: 10),
                    InputField(
                      controller: viewModel.nameController,
                      placeholder: "Öcsi",
                      icon: const Icon(Icons.edit),
                    ),
                    /*const SizedBox(height: 5),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Ezt a táborozók is látni fogják",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),*/
                    //megse latjak
                    const SizedBox(height: 25),
                    const Text("Melyik csapatnak?"),
                    const SizedBox(height: 10),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            snapshot.data!,
                            (index) => RadioListTile(
                                  title: Text('${index + 1}. csapat'),
                                  value: index.toDouble(),
                                  groupValue: viewModel.curTeamSelected,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (num? value) {
                                    setState(() {
                                      viewModel.curTeamSelected = value!.toInt();
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                ))),
                    const SizedBox(height: 25),
                    const Text("Hány pontot ér meg ez az öcsi?"),
                    const SizedBox(height: 25),
                    Slider(
                        value: viewModel.curSliderValue.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            viewModel.curSliderValue = value.toInt();
                            HapticFeedback.lightImpact();
                          });
                        },
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: viewModel.curSliderValue.round().toString()),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button3D(
                          onPressed: () {
                            if (viewModel.uploadScore()) {
                              HapticFeedback.heavyImpact();
                              _showDialog(context);
                            }
                          },
                          child: Text(
                            "Feltöltés",
                            style: TextStyle(
                              color: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Öcsi pont sikeresen feltöltve!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
