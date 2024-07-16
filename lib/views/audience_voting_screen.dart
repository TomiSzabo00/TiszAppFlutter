import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Közönségszavazás'),
      ),
      body: Container(),
    );
  }
}
