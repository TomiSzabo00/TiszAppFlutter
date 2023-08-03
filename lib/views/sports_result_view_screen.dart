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
        length: viewModel.sportsInitialized ? viewModel.availableSports.availableSports.length : 1,
        child:
        Scaffold(
          appBar: AppBar(
            title: const Text('Eredmények'),
            bottom: TabBar(
              tabs: List.generate(viewModel.sportsInitialized ? viewModel.availableSports.availableSports.length : 1,
                      (index) => viewModel.sportsInitialized ?
                  Text(viewModel.availableSports.availableSports[index]) : const Text("")),
            ),
          ),
          body:
          TabBarView(
            children:
            List.generate(viewModel.sportsInitialized ? viewModel.availableSports.availableSports.length : 1, (index) =>
                FutureBuilder(
                    future: viewModel.getNumberOfTeams(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(viewModel.groupsInitialized ? viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups.length : 0, (groupIndex) =>
                                  Column(crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Table(
                                          border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
                                          columnWidths: {for (var v in
                                          List.generate(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                          viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams.length : 0,
                                                  (i) => i)) v : const FlexColumnWidth() },
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          children:
                                          List.generate(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                          viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams.length + 1 : 0,
                                                  (indexRow) =>
                                              indexRow == 0 ? TableRow(
                                                  children:
                                                  List.generate(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                                  viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams.length + 1 : 0,
                                                          (indexCol) =>
                                                          TableCell(
                                                              child:
                                                              Container(
                                                                  child: indexCol == 0 ?
                                                                  const Text("") :
                                                                  Text(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                                                  viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams[indexCol - 1].toString() : indexCol.toString()))
                                                          )
                                                  )
                                              ) :
                                              TableRow(
                                                  children:
                                                  List.generate(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                                  viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams.length + 1 : 0,
                                                          (indexCol) =>
                                                          TableCell(child:
                                                          Container(color: indexCol == indexRow ? Colors.black : null,child:
                                                          indexCol == 0 ?
                                                          Text(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                                          viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams[indexRow - 1].toString() : indexRow.toString()) :
                                                          Text(viewModel.initializedResults ? viewModel.getResult(indexRow, indexCol, viewModel.getAvailableSports()[index], groupIndex) : "X"),
                                                          )
                                                          )
                                                  )
                                              )
                                          )),
                                      const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Table(border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
                                          columnWidths: {for (var v in List.generate(6,
                                                  (i) => i)) v : const FlexColumnWidth() },
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          children: List.generate(viewModel.groupsInitialized && viewModel.sportsInitialized ?
                                          viewModel.allGroups.allGroups[viewModel.availableSports.availableSports[index]]!.groups[groupIndex].teams.length + 1 : 0,
                                                  (indexRow) =>
                                              indexRow == 0 ? const TableRow(
                                                  children: [
                                                    TableCell(child: Text("#")),
                                                    TableCell(child: Text("Csapat")),
                                                    TableCell(child: Text("LG")),
                                                    TableCell(child: Text("KG")),
                                                    TableCell(child: Text("GK")),
                                                    TableCell(child: Text("P")),
                                                  ])
                                                  : TableRow(
                                                children: List.generate(6, (attrIndex) => Text(viewModel.getStats(index, groupIndex, indexRow, attrIndex).toString()))
                                              ))
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],)
                              )
                          )
                        ;
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
