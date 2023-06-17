import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/voting_viewmodel.dart';
import 'package:provider/provider.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<VotingViewmodel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szavazás'),
      ),
      body: Container(
        ),
    );
  }
}