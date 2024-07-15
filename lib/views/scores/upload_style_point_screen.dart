// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/style_points_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/viewmodels/style_points_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class UploadStylePointScreen extends StatefulWidget {
  const UploadStylePointScreen({super.key});

  @override
  UploadStylePointScreenState createState() => UploadStylePointScreenState();
}

class UploadStylePointScreenState extends State<UploadStylePointScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final viewModel = context.watch<StylePointsViewModel>();
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          viewModel.getNumberOfTeams(),
          viewModel.getMaxNumberOfStylePoints(),
          viewModel.getAreStylePointsPerTeam()
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int numberOfTeams = tryCast<int>(snapshot.data?[0]) ?? 4;
            int maxNumberOfStylePoints = tryCast<int>(snapshot.data?[1]) ?? 1;
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Melyik csapatnak adod a stíluspontot?"),
                    const SizedBox(height: 10),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            numberOfTeams,
                            (index) => RadioListTile(
                                  title: Text('${index + 1}. csapat'),
                                  value: index.toDouble(),
                                  groupValue: viewModel.curTeamSelected,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (num? value) {
                                    setState(() {
                                      viewModel.curTeamSelected =
                                          value!.toInt();
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                ))),
                    const SizedBox(height: 25),
                    RichText(
                      text: TextSpan(
                        text: 'Figyelem! ',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkTheme ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Egy nap alatt',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          if (viewModel.isStylePointsPerTeam)
                            const TextSpan(
                              text: ', egy csapatnak',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          const TextSpan(
                            text: ' maximum ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: '$maxNumberOfStylePoints',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const TextSpan(
                            text: ' stíluspontot adhatsz!',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button3D(
                          onPressed: () async {
                            final result = await viewModel.uploadScore();
                            if (result == UploadResult.noTeamSelected) {
                              _showDialog(context,
                                  message: "Nincs kiválasztva csapat!");
                            } else if (result == UploadResult.limitReached) {
                              _showDialog(context,
                                  message:
                                      "Ma már nem adhatsz több stíluspontot ennek a csapatnak!");
                            } else {
                              _showDialog(context,
                                  message: "Sikeres feltöltés!");
                            }
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

  void _showDialog(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
