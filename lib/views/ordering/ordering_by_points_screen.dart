import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/viewmodels/ordering_by_points_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/input_field.dart';

class OrderingByPointsScreen extends StatefulWidget {
  const OrderingByPointsScreen({super.key});

  @override
  OrderingByPointsScreenState createState() => OrderingByPointsScreenState();
}

class OrderingByPointsScreenState extends State<OrderingByPointsScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<OrderingByPointsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.subscribeToMaxPointChanges();
      viewModel.getNumberOfTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderingByPointsViewModel>();
    return Scaffold(
      body: StreamBuilder(
        stream: viewModel.votingStateStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case VotingState.notStarted:
                return _notStartedScreen(viewModel);
              case VotingState.inProgress:
                return _votingInProgress(viewModel);
              case VotingState.finished:
                return _finishedScreen();
              default:
                return _notStartedScreen(viewModel);
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _notStartedScreen(OrderingByPointsViewModel viewModel) {
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          const Text("Jelenleg nincs aktív skálázás",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 20),
          const Text("Mennyi legyen a skálázás maximuma?"),
          const SizedBox(height: 20),
          SizedBox(
            width: 100,
            child: InputField(
              controller: viewModel.maxController,
              placeholder: "10",
              isNumber: true,
            ),
          ),
          const SizedBox(height: 20),
          Button3D(
            onPressed: () {
              viewModel.startVoting();
            },
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  "Szavazás indítása",
                  style: TextStyle(
                    color: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _votingInProgress(OrderingByPointsViewModel viewModel) {
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return StreamBuilder(
      stream: viewModel.didUserUploadScores(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                const Text("Sikeresen feltöltötted a pontokat"),
                const SizedBox(height: 40),
                Button3D(
                  onPressed: () {
                    _showAreYouSureDialog(context);
                  },
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Text(
                        "Szarvazás befejezése",
                        style: TextStyle(
                          color: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return _votingScreen(viewModel);
      },
    );
  }

  Widget _votingScreen(OrderingByPointsViewModel viewModel) {
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Add meg, hogy melyik csapat hány pontot kapjon a skálán'),
            Text('A skála 1 - ${viewModel.maxPoints}-ig megy'),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.numberOfTeams,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${index + 1}. csapat"),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 100,
                        child: InputField(
                          controller: viewModel.scoreControllers.length > index
                              ? viewModel.scoreControllers[index]
                              : TextEditingController(),
                          placeholder: "1-${viewModel.maxPoints}",
                          isNumber: true,
                          onChanged: () {
                            viewModel.scoreChanged(index, viewModel.scoreControllers[index].text);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Button3D(
              onPressed: () {
                if (viewModel.uploadScores()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pontok feltöltve"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Hibás vagy hiányzó pontok"),
                    ),
                  );
                }
              },
              width: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    "Pontok feltöltése",
                    style: TextStyle(
                      color: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _finishedScreen() {
    return const Center(
      child: Text("Pontozás befejeződött"),
    );
  }

  void _showAreYouSureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Biztosan befejezed a szavazást?"),
          content: const Text("A szavazás befejezése után senki nem tud több pontot adni."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Mégsem"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final viewModel = context.read<OrderingByPointsViewModel>();
                viewModel.finishVoting();
              },
              child: const Text("Igen"),
            ),
          ],
        );
      },
    );
  }
}
