import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/viewmodels/audience_voting_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:fl_chart/fl_chart.dart';

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
    Provider.of<AudienceVotingViewModel>(context, listen: false).subscribeToResults();
  }

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
    final viewModel = context.watch<AudienceVotingViewModel>();
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
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
                            color: isDarkTheme ? CustomColor.btnFaceNight : CustomColor.btnTextDay,
                            width: MediaQuery.of(context).size.width / viewModel.results.length * 0.4,
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
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
    final isDarkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                  viewModel.selectOption('');
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button3D(
                onPressed: () {
                  if (!viewModel.vote()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Válassz egy párost!'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Szavazás',
                  style: TextStyle(
                      color: isDarkTheme ? CustomColor.btnTextNight : CustomColor.btnTextDay,
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
