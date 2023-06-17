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
    Provider.of<VotingViewmodel>(context, listen: false).getVotingState();
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
            //return inProgressScreen(); // TODO
          } else {
            //return finishedScreen(); // TODO
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
        Button3D(onPressed: () {},
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
}
