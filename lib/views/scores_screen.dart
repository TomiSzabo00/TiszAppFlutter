import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/score_data.dart';
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
        scores.insert(0, Score.fromSnapshot(event.snapshot));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pontállás'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  isDarkTheme ? 'images/bg2_night.png' : 'images/bg2_day.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 120,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CustomColor.semiTransparentWhite,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Text(
                        'Csapatok pontjai',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ScoreItem(
                scoreData: Score(
                    author: "",
                    name: 'Program neve',
                    score1: 1,
                    score2: 2,
                    score3: 3,
                    score4: 4),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    return ScoreItem(scoreData: scores[index]);
                  },
                ),
              )
            ],
          ),
        ));
  }
}