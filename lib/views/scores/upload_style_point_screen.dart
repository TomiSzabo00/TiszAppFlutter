import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
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
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final viewModel = context.watch<StylePointsViewModel>();
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([viewModel.getNumberOfTeams(), viewModel.getMaxNumberOfStylePoints()]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final numberOfTeams = snapshot.data?[0] ?? 4;
            final maxNumberOfStylePoints = snapshot.data?[1] ?? 1;
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
                                      viewModel.curTeamSelected = value!.toInt();
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                ))),
                    const SizedBox(height: 25),
                    RichText(
                      text: TextSpan(
                        text: 'Figyelem! ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Egy csapatnak, egy nap alatt maximum ',
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
                          const TextSpan(text: ' stíluspontot'),
                          const TextSpan(
                            text: ' adhatsz!',
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
