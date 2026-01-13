import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/audience_voting_state.dart';
import 'package:tiszapp_flutter/viewmodels/audience_voting_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

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
  void initState() {
    super.initState();
    Provider.of<AudienceVotingViewModel>(context, listen: false)
        .subscribeToResults();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AudienceVotingViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Közönségszavazás'),
      ),
      body: widget.isAdmin ? _adminScreen(viewModel) : _userScreen(viewModel),
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
                          final bool isResultVisible =
                              tryCast<bool>(snapshot.data) ?? false;
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          StreamBuilder(
            stream: viewModel.getVotingState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data!;
                return Column(
                  children: [
                    Text(
                      'A szavazás jelenleg ${state.displayValue}.',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    _visibilityToggle(),
                    if (state == AudienceVotingState.voting) ...[
                      _resultsVisibleScreen(),
                      const SizedBox(height: 20),
                      _inProgressAdminButtons(),
                    ] else if (state == AudienceVotingState.paused) ...[
                      _adminPausedScreen(),
                    ] else if (state == AudienceVotingState.stopped) ...[
                      _adminStoppedScreen(),
                    ],
                  ],
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

  Widget _visibilityToggle() {
    final viewModel = context.watch<AudienceVotingViewModel>();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: StreamBuilder(
        stream: viewModel.isResultVisible(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool isResultVisible = tryCast<bool>(snapshot.data) ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Az eredményeket lássák a diákok?',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isResultVisible,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    viewModel.setResultVisibility(value);
                  },
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _inProgressAdminButtons() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Button3D(
          onPressed: () {
            context
                .read<AudienceVotingViewModel>()
                .setVotingState(AudienceVotingState.paused);
          },
          child: Text(
            'Szüneteltetés',
            style: TextStyle(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        Button3D(
          onPressed: () {
            final viewModel = context.read<AudienceVotingViewModel>();
            viewModel.setVotingState(AudienceVotingState.stopped);
            viewModel.deleteVotes();
          },
          child: Text(
            'Törlés',
            style: TextStyle(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _adminPausedScreen() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      children: [
        _resultsVisibleScreen(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Button3D(
              onPressed: () {
                context
                    .read<AudienceVotingViewModel>()
                    .setVotingState(AudienceVotingState.voting);
              },
              child: Text(
                'Folytatás',
                style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Button3D(
              onPressed: () {
                final viewModel = context.read<AudienceVotingViewModel>();
                viewModel.setVotingState(AudienceVotingState.stopped);
                viewModel.deleteVotes();
              },
              child: Text(
                'Törlés',
                style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _adminStoppedScreen() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final viewModel = context.watch<AudienceVotingViewModel>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: viewModel.newPairTextController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    hintText: 'Új páros (Ember1 - Ember2)',
                    isDense: true,
                  ),
                ),
              ),
            ),
            Button3D(
              width: MediaQuery.of(context).size.width * 0.15,
              height: 60,
              onPressed: () {
                viewModel.addVotingOption();
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
        StreamBuilder(
          stream: viewModel.getVotingOptions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<String> options = snapshot.data ?? [];
              return Column(
                children: options.map((option) {
                  return ListTile(
                    title: Text(option),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        viewModel.deleteVotingOption(option);
                      },
                    ),
                  );
                }).toList(),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        const SizedBox(height: 20),
        Button3D(
          onPressed: () {
            final viewModel = context.read<AudienceVotingViewModel>();
            viewModel.setVotingState(AudienceVotingState.voting);
          },
          child: Text(
            'Indítás',
            style: TextStyle(
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _votingClosedScreen() {
    return const Center(child: Text('A szavazás jelenleg nincs nyitva.'));
  }

  Widget _resultsHiddenScreen() {
    return const Center(child: Text('A szavazatodat sikeresen rögzítettük!'));
  }

  Widget _resultsVisibleScreen() {
    final viewModel = context.watch<AudienceVotingViewModel>();
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              children: [
                const Text(
                  'Legtöbb szavazatot kapta:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  viewModel.getWinner(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true, reservedSize: 30, interval: 1)),
                  bottomTitles: AxisTitles(
                    drawBelowEverything: false,
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: getTitles,
                      reservedSize: 60,
                    ),
                  ),
                ),
                barGroups: viewModel.results.entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: viewModel.results.keys.toList().indexOf(entry.key),
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: entry.value.toDouble(),
                            color: isDarkTheme
                                ? CustomColor.btnFaceNight
                                : CustomColor.btnTextDay,
                            width: MediaQuery.of(context).size.width /
                                viewModel.results.length *
                                0.4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _votingScreen(AudienceVotingViewModel viewModel) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Válaszd ki azt az EGY párost, akik szerinted a legjobbak voltak:'),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: viewModel.getVotingOptions(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<String> options = snapshot.data ?? [];
                  if (options.isEmpty) {
                    viewModel.selectOption('');
                    return const Center(
                        child: Text('Nincsenek lehetőségek. :('));
                  }
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button3D(
                onPressed: () {
                  if (!viewModel.vote()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Nem választottál ki egy párost sem, vagy a szavazás már lezárult!'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Szavazás',
                  style: TextStyle(
                      color: isDarkTheme
                          ? CustomColor.btnTextNight
                          : CustomColor.btnTextDay,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final viewModel = context.watch<AudienceVotingViewModel>();
    const style = TextStyle(
      fontSize: 14,
    );
    Widget text;
    final index = value.toInt();
    final names = viewModel.results.keys.toList();
    text = index < names.length
        ? Text(
            names[index],
            style: style,
          )
        : const SizedBox();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      angle: -1.2,
      child: text,
    );
  }
}
