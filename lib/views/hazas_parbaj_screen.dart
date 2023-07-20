import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/hazas_parbaj_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import '../widgets/hazas_parbaj_tile.dart';
import 'hazas_parbaj_voting_screen.dart';

class HazasParbajScreen extends StatefulWidget {
  const HazasParbajScreen({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  HazasParbajScreenState createState() => HazasParbajScreenState();
}

class HazasParbajScreenState extends State<HazasParbajScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HazasParbajViewModel>(context, listen: false)
        .subscribeToUserChanges();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HazasParbajViewModel>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Házaspárbaj'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Akik már jelentkeztek:',
                    style: TextStyle(fontSize: 16.0),
                  )),
              const SizedBox(height: 20.0),
              Expanded(child: () {
                if (viewmodel.signedUpPairs.isEmpty) {
                  return const Center(
                      child: Text('Még senki sem jelentkezett!',
                          style: TextStyle(fontSize: 20.0)));
                } else {
                  viewmodel.signedUpPairs.sort(
                      (a, b) => (a.votedOut ? 1 : 0) - (b.votedOut ? 1 : 0));
                  return Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                          child: SlidableAutoCloseBehavior(
                        child: Column(
                          children: List.generate(
                              viewmodel.signedUpPairs.length, (index) {
                            if (widget.isAdmin) {
                              final key = Key(
                                  viewmodel.signedUpPairs[index].user.uid +
                                      viewmodel.signedUpPairs[index].name1 +
                                      viewmodel.signedUpPairs[index].name2 +
                                      viewmodel.signedUpPairs[index].team);
                              return Slidable(
                                  key: key,
                                  groupTag: 0,
                                  endActionPane: ActionPane(
                                      extentRatio: 0.3,
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) => viewmodel
                                              .removeFromPairs(viewmodel
                                                  .signedUpPairs[index]),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Törlés',
                                        ),
                                      ]),
                                  child: HazasTile(
                                      data: viewmodel.signedUpPairs[index]));
                            }
                            return HazasTile(
                                data: viewmodel.signedUpPairs[index]);
                          }),
                        ),
                      )));
                }
              }()),
              const SizedBox(height: 20.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Button3D(
                      onPressed: () =>
                          _showSignUpModalSheet(viewmodel, isDarkTheme),
                      child: Text(
                        'Jelentkezés',
                        style: TextStyle(
                          color: isDarkTheme
                              ? CustomColor.btnTextNight
                              : CustomColor.btnTextDay,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.isAdmin) ...[
                      const SizedBox(width: 20.0),
                      Visibility(
                        visible: widget.isAdmin,
                        child: Button3D(
                          onPressed: () =>
                              _showVotingModalSheet(viewmodel, isDarkTheme),
                          child: Text(
                            'Szavazás indítása',
                            style: TextStyle(
                              color: isDarkTheme
                                  ? CustomColor.btnTextNight
                                  : CustomColor.btnTextDay,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ],
          )),
    );
  }

  void _showSignUpModalSheet(HazasParbajViewModel vm, bool isDarkTheme) {
    bool showError = false;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jelentkezés',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Add meg a saját és a párod nevét, valamint a csapatotok számát!',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.name1Controller,
                      decoration: InputDecoration(
                        labelText: 'Saját neved',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 20,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.name2Controller,
                      decoration: InputDecoration(
                        labelText: 'Párod neve',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 20,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.teamController,
                      decoration: InputDecoration(
                        labelText: 'Csapat száma (1-4)',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 1,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    Button3D(
                        width: 140,
                        onPressed: () async {
                          if (vm.name1Controller.text.isEmpty ||
                              vm.name2Controller.text.isEmpty ||
                              vm.teamController.text.isEmpty) {
                            setState(() {
                              showError = true;
                            });
                            return;
                          }
                          final shouldShowError = await vm.signUp();
                          setState(() {
                            showError = shouldShowError;
                          });
                          if (!showError) Navigator.pop(context);
                        },
                        child: Text(
                          'Jelentkezés',
                          style: TextStyle(
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
              ));
        });
      },
    );
  }

  void _showVotingModalSheet(HazasParbajViewModel vm, bool isDarkTheme) {
    bool showError = false;
    int numOfPairs = vm.signedUpPairs.length;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '''Egy szervező (beszéljétek meg, hogy ki) indítsa el a szavazást! Amikor elindul a szavazás, mindenki szavazhat, hogy mely párokat tartja a legrosszabbnak. Ezek után, ugyanaz a szervező, aki elindította a szavazást, zárja le azt.''',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 20.0),
                    if (vm.votingState == VotingState.notStarted)
                      TextField(
                          controller: vm.num,
                          decoration: InputDecoration(
                            labelText: 'Hány párt akartok kiszavazni?',
                            errorText: showError ? 'Kötelező mező!' : null,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          maxLength: 2,
                          autocorrect: false,
                          onChanged: (_) {
                            setState(() {
                              showError = false;
                            });
                          }),
                    const SizedBox(height: 20.0),
                    Button3D(
                        width: 140,
                        child: Text(
                          'Szavazás',
                          style: TextStyle(
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          if (vm.num.text.isEmpty &&
                              vm.votingState == VotingState.notStarted) {
                            setState(() {
                              showError = true;
                            });
                            return;
                          }
                          if (vm.num.text.isNotEmpty) {
                            vm.setNumberOfPairsToVoteOff();
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HazasParbajVotingScreen(
                                      numOfPairs: numOfPairs)));
                          vm.startVoting();
                        }),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            );
          });
        });
  }
}
