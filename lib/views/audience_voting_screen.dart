import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/viewmodels/audience_voting_viewmodel.dart';

class AudienceVotingScreen extends StatefulWidget {
  const AudienceVotingScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  AudienceVotingScreenState createState() => AudienceVotingScreenState();
}

class AudienceVotingScreenState extends State<AudienceVotingScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AudienceVotingViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Közönségszavazás'),
      ),
      body: widget.isAdmin ? _userScreen(viewModel) : _userScreen(viewModel),
    );
  }

  Widget _userScreen(AudienceVotingViewModel viewModel) {
    return StreamBuilder(
      stream: viewModel.isVotingOpen(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final bool isOpen = tryCast<bool>(snapshot.data) ?? false;
          if (isOpen) {
            return StreamBuilder(
              stream: viewModel.didUserVote(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final bool didVote = tryCast<bool>(snapshot.data) ?? true;
                  if (didVote) {
                    return StreamBuilder(
                      stream: viewModel.isResultVisible(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final bool isResultVisible = tryCast<bool>(snapshot.data) ?? false;
                          if (isResultVisible) {
                            return _resultsVisibleScreen();
                          }
                          return _resultsHiddenScreen();
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                  return _votingScreen(viewModel);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }
          return _votingClosedScreen();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _adminScreen(AudienceVotingViewModel viewModel) {
    return Container();
  }

  Widget _votingClosedScreen() {
    return const Center(child: Text('A szavazás jelenleg nincs nyitva.'));
  }

  Widget _resultsHiddenScreen() {
    return const Center(child: Text('A szavazatodat sikeresen rögzítettük!'));
  }

  Widget _resultsVisibleScreen() {
    // TODO
    return const Center(child: Text('A szavazás eredményeit megtekintheted!'));
  }

  Widget _votingScreen(AudienceVotingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Válaszd ki azt az EGY párost, akik szerinted a legjobbak voltak:'),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: viewModel.getVotingOptions(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<String> options = snapshot.data ?? [];
                if (options.isEmpty) {
                  return const Center(child: Text('Nincsenek lehetőségek. :('));
                }
                return SingleChildScrollView(
                  child: Column(
                    children: options.map((option) {
                      return RadioListTile(
                        title: Text(option),
                        value: option,
                        groupValue: viewModel.selectedOption,
                        onChanged: (_) {
                          viewModel.selectOption(option);
                        },
                        selected: viewModel.selectedOption == option,
                      );
                    }).toList(),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
