import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/voting_state.dart';
import 'package:tiszapp_flutter/viewmodels/voting_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class VotingScreen extends StatefulWidget {
  VotingScreen({Key? key}) : super(key: key);

  bool isDarkTheme = false;

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<VotingViewmodel>(context, listen: false).listenToVotingState();
  }

  @override
  Widget build(BuildContext context) {
    widget.isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<VotingViewmodel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szavazás'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: (() {
          if (viewModel.votingState == VotingState.notStarted) {
            return notStartedScreen();
          } else if (viewModel.votingState == VotingState.inProgress) {
            if (viewModel.isVoteSent) {
              return votingSentScreen();
            } else {
              return votingScreen(viewModel);
            }
          } else {
            return finishedScreen();
          }
        }()),
      ),
    );
  }

  Widget notStartedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Jelenleg nincs aktív szavazás.'),
        const SizedBox(height: 40),
        Button3D(
          onPressed: () {
            Provider.of<VotingViewmodel>(context, listen: false).startVoting();
          },
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                "Szavazás indítása",
                style: TextStyle(
                  color: widget.isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget votingScreen(VotingViewmodel viewModel) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'Rendezd át a csapatokat teljesítményük alapján!\nElőre a legjobbakat, hátra a leggyengébbeket!'),
          const SizedBox(height: 40),
          Expanded(
            child: FutureBuilder(
              future: viewModel.getTeams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ReorderableListView(
                    children: <Widget>[
                      for (int i = 0; i < viewModel.teams.length; i++)
                        ListTile(
                          key: Key(i.toString()),
                          tileColor: i.isEven ? evenItemColor : oddItemColor,
                          title: Text('${viewModel.teams[i]}. csapat'),
                          trailing: const Icon(Icons.drag_handle),
                        )
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final int item = viewModel.teams.removeAt(oldIndex);
                        viewModel.teams.insert(newIndex, item);
                      });
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          const SizedBox(height: 40),
          Button3D(
            onPressed: () {
              showSendVoteConfirmationDialog(context);
            },
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  "Sorrend beküldése",
                  style: TextStyle(
                    color: widget.isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
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

  Widget votingSentScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('A szavazatod sikeresen beküldésre került!'),
        const SizedBox(height: 40),
        Button3D(
          onPressed: () {
            Provider.of<VotingViewmodel>(context, listen: false).resetVote();
          },
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                "Új szavazat beküldése",
                style: TextStyle(
                  color: widget.isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Button3D(
          onPressed: () {
            showEndVotingConfirmationDialog(context);
          },
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                "Szavazás lezárása",
                style: TextStyle(
                  color: widget.isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget finishedScreen() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text('A szavazás lezárult!\nÍme az összesített sorrend:'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: FutureBuilder(
              future: Provider.of<VotingViewmodel>(context, listen: false)
                  .getVotingResults(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            Text('${snapshot.data![index]}'),
                        tileColor: index.isEven ? evenItemColor : oddItemColor,
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          const SizedBox(height: 40),
          Button3D(
            onPressed: () {
              showCloseVoteConfirmationDialog(context);
            },
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  "Szavazás törlése",
                  style: TextStyle(
                    color: widget.isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
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

  showSendVoteConfirmationDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Mégse"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Igen"),
      onPressed: () {
        Provider.of<VotingViewmodel>(context, listen: false).sendVote();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Beküldöd a szavazatod?"),
      content: const Text(
          "Biztos vagy benne, hogy ezt a sorrendet szeretnéd beküldeni?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showEndVotingConfirmationDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Mégse"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Igen"),
      onPressed: () {
        Provider.of<VotingViewmodel>(context, listen: false).endVote();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Lezárod a szavazást?"),
      content:
          const Text("Biztos vagy benne, hogy le akarod zárni a szavazást?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showCloseVoteConfirmationDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Mégse"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Igen"),
      onPressed: () {
        Provider.of<VotingViewmodel>(context, listen: false).closeVote();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Törlöd a szavazást?"),
      content:
          const Text("Biztos vagy benne, hogy törölni akarod a szavazást?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
