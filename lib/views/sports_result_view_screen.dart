import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sports_viewmodel.dart';

class SportsResultViewScreen extends StatefulWidget {
  const SportsResultViewScreen({super.key});

  @override
  State<SportsResultViewScreen> createState() => _SportsResultViewScreenState();
}

class _SportsResultViewScreenState extends State<SportsResultViewScreen>{
  @override
  void initState() {
    super.initState();
    Provider.of<SportsViewModel>(context, listen: false).getData();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SportsViewModel>();
    return DefaultTabController(
        length: viewModel.initializedResults ? viewModel.sportsResults.resultMap.length : 1,
        child:
        Scaffold(
          appBar: AppBar(
            title: const Text('Eredmények'),
            bottom: TabBar(
              tabs: List.generate(viewModel.initializedResults ? viewModel.sportsResults.resultMap.length : 1, (index) => Text(viewModel.getAvailableSports()[index])),
            ),
          ),
          body:
          TabBarView(
            children:
            List.generate(viewModel.getAvailableSports().length, (index) =>
                FutureBuilder(
                    future: viewModel.getNumberOfTeams(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Table(
                            border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
                            columnWidths: {for (var v in List.generate(snapshot.data! + 1, (index) => index)) v : const FlexColumnWidth() },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: List.generate(snapshot.data! + 1,
                                    (indexRow) =>
                                indexRow == 0 ? TableRow(
                                    children:
                                    List.generate(snapshot.data! + 1,
                                            (indexCol) =>
                                        indexCol == 0 ? const Text("") :
                                        Text(indexCol.toString()))
                                ) :
                                TableRow(
                                    children:
                                    List.generate(snapshot.data! + 1,
                                            (indexCol) =>
                                        indexCol == 0 ?
                                        Text(indexRow.toString()) :
                                        Text(viewModel.initializedResults ? viewModel.getResult(indexRow, indexCol, viewModel.getAvailableSports()[index]) : "X")
                                    )
                                )
                            ));
                      }
                      else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }
                )),
          ),
        )
    );
  }




}
