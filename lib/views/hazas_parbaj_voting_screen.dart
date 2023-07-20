import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/hazas_parbaj_data.dart';
import 'package:tiszapp_flutter/viewmodels/hazas_parbaj_viewmodel.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class HazasParbajVotingScreen extends StatefulWidget {
  const HazasParbajVotingScreen({Key? key, required this.numOfPairs})
      : super(key: key);
  final int numOfPairs;
  @override
  HazasParbajVotingScreenState createState() => HazasParbajVotingScreenState();
}

class HazasParbajVotingScreenState extends State<HazasParbajVotingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HazasParbajViewModel>(context, listen: false)
        .subscribeToUserChanges();
  }

  bool ischecked = true;
  late List<bool> checked = List.generate(widget.numOfPairs, (index) => false);

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HazasParbajViewModel>();
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Házaspárbaj szavazás"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (viewmodel.votingState == VotingState.inProgress)
              Text(
                '${viewmodel.pairsToVoteOff} db párra kell szavaznod.',
              ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: () {
                if (viewmodel.votingState == VotingState.notStarted ||
                    viewmodel.votingState == VotingState.finished) {
                  return const Center(
                    child: Text('Nincs aktív szavazás'),
                  );
                } else {
                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                        child: Column(
                            children: List.generate(
                                viewmodel.signedUpPairs.length, (index) {
                      if (!viewmodel.signedUpPairs[index].votedOut) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              )),
                          child: CheckboxListTile(
                            tileColor: Colors.grey[200],
                            title: Text(
                              '${viewmodel.signedUpPairs[index].name1} és ${viewmodel.signedUpPairs[index].name2}',
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              '${viewmodel.signedUpPairs[index].team}. csapat',
                              style: const TextStyle(color: Colors.black),
                            ),
                            value: checked[index],
                            onChanged: (bool? value) {
                              setState(() {
                                checked[index] = value!;
                              });
                            },
                          ),
                        );
                      } else {
                        return const SizedBox(height: .0001);
                      }
                    }))),
                  );
                }
              }(),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button3D(
                    onPressed: () => _sendVotes(viewmodel),
                    child: Text(
                      'Beküldés',
                      style: TextStyle(
                        color: isDarkTheme
                            ? CustomColor.btnTextNight
                            : CustomColor.btnTextDay,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50.0),
                  Button3D(
                    onPressed: () => _endVoting(viewmodel, isDarkTheme),
                    child: Text(
                      'Lezárás',
                      style: TextStyle(
                        color: isDarkTheme
                            ? CustomColor.btnTextNight
                            : CustomColor.btnTextDay,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _endVoting(HazasParbajViewModel viewmodel, bool isDarkTheme) {
    String result = '';
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    left: 20,
                    right: 20),
                child: SingleChildScrollView(
                    child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Szavazás lezárása',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Biztosan le szeretnéd zárni a szavazást?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Button3D(
                          width: 140,
                          onPressed: () {
                            viewmodel.endVoting();
                            result += viewmodel.summarizeVotes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          },
                          child: Text(
                            'Igen',
                            style: TextStyle(
                              color: isDarkTheme
                                  ? CustomColor.btnTextNight
                                  : CustomColor.btnTextDay,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                    ],
                  ),
                )));
          });
        });
  }

  void _sendVotes(HazasParbajViewModel viewmodel) {
    if (checked.where((element) => element == true).length !=
        viewmodel.pairsToVoteOff) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Nem megfelelő számú párt jelöltél ki! ${viewmodel.pairsToVoteOff} db párt kell kiválasztanod! '),
        ),
      );
    } else {
      List<HazasParbajData> votedPairs = [];
      for (var i = 0; i < checked.length; i++) {
        if (checked[i]) {
          votedPairs.add(viewmodel.signedUpPairs[i]);
        }
      }
      viewmodel.submitVote(votedPairs);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sikeres szavazás'),
        ),
      );
    }
  }
}
