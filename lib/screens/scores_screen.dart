import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/data/score_data.dart';
import 'package:tiszapp_flutter/widgets/score_item.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late DatabaseReference scoresRef;

  List<Score> scores = [];

  @override
  void initState() {
    scoresRef = FirebaseDatabase.instance.ref().child("debug/scores");
    scoresRef.onChildAdded.listen((event) {
      setState(() {
        scores.add(Score.fromSnapshot(event.snapshot));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontállás'),
      ),
      body: ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          return ScoreItem(scoreData: scores[index]);
        },
      ),
    );
  }
}
